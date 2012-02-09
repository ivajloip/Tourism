require 'spec_helper'

describe ArticlesController do
  describe "GET index" do
    before do 
      Article.stub_chain :where, :order_by, :page, :per => 'articles'
    end

    it "paginates all articles to @articles" do
      Article.where.order_by.page.should_receive(:per)
      get :index, :page => '1'
      assigns(:articles).should == 'articles'
    end

    it "search the correct page for pagination" do
      Article.where.order_by.should_receive(:page).with('3')
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
end
