require 'spec_helper'

describe ArticlesController do
  describe "GET index" do
    before do 
      Article.stub_chain :all_visible, :order_by, :page, :per => 'articles'
    end

    it "paginates all articles to @articles" do
      Article.should_receive(:all_visible).with(nil)

      Article.all_visible.order_by.page.should_receive(:per)

      get :index, :page => '1'
      assigns(:articles).should == 'articles'
    end

    it "search the correct page for pagination" do
      Article.all_visible.order_by.should_receive(:page).with('3')
      get :index, :page => '3'
    end
  end

  describe "GET show" do
    let(:article) { build_stubbed(:article) }

    before do
      Article.stub :find => article
    end

    it "looks up the article by id" do
      Article.should_receive(:find).with('42').and_return(article)
      get :show, :id => '42'
    end

    it "assigns the article to @article" do
      get :show, :id => '42'
      assigns(:article).should eq article
    end

    it "assigns the comments to @comments" do
      article.stub_chain :comments, :order_by, :page, :per => 'comments'
      get :show, :id => '42'
      assigns(:comments).should eq 'comments'
    end

    it "paginate the comments" do
      article.stub_chain :comments, :order_by, :page, :per
      article.comments.order_by.should_receive(:page).with('3')
      get :show, :id => '42', page: 3
    end
  end


  describe "POST new" do
    let(:current_user) { create(:user) }
    let(:article) { build_stubbed(:article) }

    before do
      Article.stub new: article

      sign_in current_user
    end

    def new_article
      post :new
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user

      new_article

      response.should redirect_to(new_user_session_url)
    end

    it "assigns the article to @article" do
      new_article

      controller.should assign_to(:article).with(article)
    end
  end


  describe "POST edit" do
    let(:current_user) { create(:user) }
    let(:article_id) { BSON::ObjectId.new.to_s }
    let(:article) { build_stubbed(:article) }

    before do
      Article.stub :find => article
      article.stub editable_by?: true

      sign_in current_user
    end
    
    def edit_article
      get :edit, :id => article_id
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user

      edit_article

      response.should redirect_to(new_user_session_url)
    end

    it "assigns the article to @article" do
      edit_article

      controller.should assign_to(:article).with(article)
    end

    it "looks up the article by id" do
      Article.should_receive(:find).with(article_id).and_return(article)
      edit_article
    end

    it "denies access to users who cannot edit the article" do
      article.should_receive(:editable_by?).and_return(false)
      edit_article
      controller.should redirect_to article_url(article)
    end
  end
    
  describe "POST create" do
    let(:current_user) { create(:user) }
    let(:article) { build_stubbed(:article) }

    before do
      Article.stub new: article
      article.stub :author=
      article.stub :save

      sign_in current_user
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user

      post :create

      response.should redirect_to(new_user_session_url)
    end

    it "assigns the article to @article" do
      post :create

      controller.should assign_to(:article).with(article)
    end

    it "creates a new article with the given attributes" do
      Article.should_receive(:new).with('article-attributes')

      post :create, article: 'article-attributes'
    end

    it "creates a new article on behalf of the user" do
      article.should_receive(:author=).with(current_user)

      post :create
    end

    it "attempts to save the article" do
      article.should_receive :save

      post :create
    end

    it "redirects to the article on success" do
      article.stub save: true

      post :create

      controller.should redirect_to(article_url(article)) 
    end

    it "redisplays the article for editing on failure" do
      article.stub save: false

      post :create

      controller.should render_template('articles/new', 'layouts/application')
    end
  end

  describe "PUT update" do
    let(:current_user) { create(:user) }
    let(:article_id) { BSON::ObjectId.new.to_s }
    let(:article) { build_stubbed(:article) }

    before do
      Article.stub find: article
      article.stub :update_attributes
      article.stub editable_by?: true

      sign_in current_user
    end

    def update_article args = {}
      put(:update, { id: article_id }.merge(args))
    end

    it "assigns the article to @article" do
      update_article
      controller.should assign_to(:article).with(article)
    end

    it "denies access to users who cannot edit the article" do
      article.should_receive(:editable_by?).with(current_user).and_return(false)
      update_article
      response.should redirect_to article_url(article)
    end

    it "looks up the article by id" do
      Article.should_receive(:find).with(article_id)
      update_article
    end

    it "attempts to update the article with params[:article]" do
      article.should_receive(:update_attributes).with('article-attributes')
      update_article article: 'article-attributes'
    end

    it "redirects to the article on success" do
      article.stub update_attributes: true
      update_article
      controller.should redirect_to article
    end

    it "redisplays the form on failure" do
      article.stub update_attributes: false
      update_article
      controller.should render_template :edit
    end
  end

  describe "DELETE destroy" do
    let(:current_user) { create(:user) }
    let(:article_id) { BSON::ObjectId.new.to_s }
    let(:article) { build_stubbed(:article) }

    before do
      Article.stub find: article
      article.stub :editable_by? => true
      article.stub :destroy

      sign_in current_user
    end

    def delete_article
      delete :destroy,  id: article_id
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user

      delete_article

      response.should redirect_to(new_user_session_url)
    end

    it "denies access to users who cannot edit the article" do
      article.should_receive(:editable_by?).with(current_user).and_return(false)
      delete_article
      response.should redirect_to article_url(article)
    end

    it "looks up the article by id" do
      Article.should_receive(:find).with(article_id)
      delete_article
    end

    it "attempts to update the article with params[:article]" do
      article.should_receive(:destroy)
      delete_article
    end

    it "redirects to the articles on success" do
      delete_article
      controller.should redirect_to articles_url
    end
  end


  describe "POST like/dislike/follow/unfollow" do
    let(:current_user) { create(:user) }
    let(:article_id) { BSON::ObjectId.new.to_s }
    let(:article) { build_stubbed(:article) }

    before do
      Article.stub :find => article
      article.stub :like
      article.stub :dislike
      article.stub :follow
      article.stub :unfollow
      article.stub :save

      sign_in current_user
    end

    def like_article
      post :like, id: article_id
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user

      like_article
      response.should redirect_to(new_user_session_url)
    end

    it "looks up the article by id" do
      Article.should_receive(:find).with(article_id)
      like_article
    end

    it "assigns the article to @article" do
      like_article
      controller.should assign_to(:article).with(article)
    end

    it "likes the article on behalf of the user" do
      article.should_receive(:like).with(current_user)
      article.should_receive(:save)
      like_article
    end

    it "redirects to the article on like success" do
      article.stub save: true
      like_article

      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "Article was successfully liked."
    end

    it "redirects to the article on like failure" do
      article.stub save: false
      like_article
      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "There was an error liking this article."
    end

    it "renders the correct template on ajax success" do
      article.stub save: true
      xhr :post, :like, id: article_id

      controller.should render_template('votes') 
    end

    it "does nothing on ajax failure" do
      article.stub save: false
      xhr :post, :like, id: article_id

      controller.should_not render_template('votes') 
    end

    it "dislikes the article on behalf of the user" do
      article.should_receive(:dislike).with(current_user)
      article.should_receive(:save)

      post :dislike, id: article_id
    end

    it "redirects to the article on dislike success" do
      article.stub save: true
      post :dislike, id: article_id

      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "Article was successfully disliked."
    end

    it "redirects to the article on dislike failure" do
      article.stub save: false
      post :dislike, id: article_id
      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "There was an error disliking this article."
    end

    it "follows the article on behalf of the user" do
      article.should_receive(:follow).with(current_user)
      article.should_receive(:save)

      post :follow, id: article_id
    end

    it "redirects to the article on follow success" do
      article.stub save: true
      post :follow, id: article_id

      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "Article was successfully followed."
    end

    it "redirects to the article on follow failure" do
      article.stub save: false
      post :follow, id: article_id
      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "There was an error following this article."
    end

    it "unfollows the article on behalf of the user" do
      article.should_receive(:unfollow).with(current_user)
      article.should_receive(:save)

      post :unfollow, id: article_id
    end

    it "redirects to the article on unfollow success" do
      article.stub save: true
      post :unfollow, id: article_id

      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "Article was successfully unfollowed."
    end

    it "redirects to the article on unfollow failure" do
      article.stub save: false
      post :unfollow, id: article_id
      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "There was an error unfollowing this article."
    end
  end

  describe "GET search" do
    let(:current_user) { create(:user) }

    before do
      Article.stub_chain :all_visible, :where, :order_by, :page, :per => 'articles'

      sign_in current_user
    end

    def search_articles(article_param = {}, query_param = {}, page = 1)
      get :search, :page => page, :query => query_param, :article => article_param
    end

    it "does not require authentication" do
      sign_out current_user

      search_articles
      response.should_not redirect_to(new_user_session_url)
    end

    it "assigns the articles to @articles" do
      Article.should_receive(:all_visible).with(current_user)
      Article.all_visible.where.order_by.page.should_receive(:per)
      search_articles
      assigns(:articles).should == 'articles'
    end

    it "synthesize correct start_date query" do
      day, month, year = Time.now.to_a[3..5]
      expected_query = { :created_at => { "$gte" => Time.new(year, month, day) } }
      query_param = { 'start_date(1i)' => year, 'start_date(2i)' => month, 'start_date(3i)' => day }

      Article.all_visible.should_receive(:where).with(expected_query)

      search_articles({}, query_param)
    end

    it "synthesize correct author_id query" do
      query_param = { :author_id => 'author_id' }

      Article.all_visible.should_receive(:where).with(query_param)

      search_articles({}, query_param)
    end
    
    it "synthesize correct title query" do
      query_param = { :title => 'title' }
      expected_query = { :title => /title/ }

      Article.all_visible.should_receive(:where).with(expected_query)

      search_articles({}, query_param)
    end

    it "synthesize correct province_id query" do
      query_param = { 'province_id' => 'province_id' }

      Article.all_visible.should_receive(:where).with(query_param)

      search_articles({}, query_param)
    end

    it "search the correct page for pagination" do
      Article.all_visible.where.order_by.should_receive(:page).with('3')
      search_articles({}, {}, 3)
    end

    it "synthesize correctly multiple params" do
      day, month, year = Time.now.to_a[3..5]

      query_param = { 'start_date(1i)' => year, 'start_date(2i)' => month, 'start_date(3i)' => day, 
                      'end_date(1i)' => year, 'end_date(2i)' => month, 'end_date(3i)' => (day + 1),
                      :title => 'title', :author_id => 'author_id', 'province_id' => 'province_id' }

      expected_dates_query = { "$gte" => Time.new(year, month, day), 
                               "$lt" => Time.new(year, month, day + 1) }

      expected_query = { :created_at => expected_dates_query, :title => /title/, 
                         'province_id' => 'province_id', :author_id => 'author_id' }

      Article.all_visible.should_receive(:where).with(expected_query)

      search_articles({}, query_param)
    end
  end
end
