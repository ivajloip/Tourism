require 'spec_helper'

describe CommentsController do
  describe "POST create" do
    let(:current_user) { Factory.create(:user) }
    let(:article_id) { BSON::ObjectId.new.to_s }
    let(:article) { build_stubbed(:article) }
    let(:comment) { build_stubbed(:comment) }

    before(:each) do
      sign_in current_user
    end

    before do
      Article.stub find: article
      article.stub_chain :comments, :new => comment
      article.stub_chain :comments, :order_by, :page, :per => [comment]
      article.stub commentable_by?: true
      comment.stub :author=
      comment.stub :save
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user

      post :create, article_id: article_id
      response.should redirect_to(new_user_session_url)
    end

    it "looks up the article by id" do
      Article.should_receive(:find).with(article_id)
      post :create, article_id: article_id
    end

    it "assigns the article to @article" do
      post :create, article_id: article_id
      controller.should assign_to(:article).with(article)
    end

    it "assigns the comment to @comment" do
      post :create, article_id: article_id
      controller.should assign_to(:comment).with(comment)
    end

    it "creates a new comment with the given attributes" do
      article.comments.should_receive(:new).with('comment-attributes')
      post :create, article_id: article_id, comment: 'comment-attributes'
    end

    it "creates a new comment on the article on behalf of the user" do
      comment.should_receive(:author=).with(current_user)
      post :create, article_id: article_id
    end

    it "attempts to save the comment" do
      comment.should_receive :save
      post :create, article_id: article_id
    end

    it "redirects to the article on success" do
      comment.stub save: true
      post :create, article_id: article_id

      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "Comment created!"
    end

    it "redisplays the comment for editing on failure" do
      comment.stub save: false
      post :create, article_id: article_id
      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should be_nil
    end

    it "renders the correct template on ajax success" do
      comment.stub save: true
      xhr :post, :create, article_id: article_id

      controller.should render_template('/articles/comments') 
    end

    it "does nothing on ajax failure" do
      xhr :post, :create, article_id: article_id

      controller.should_not render_template('/articles/comments') 
    end
  end
  
  describe "POST like/dislike" do
    let(:current_user) { Factory.create(:user) }
    let(:article_id) { BSON::ObjectId.new.to_s }
    let(:comment_id) { BSON::ObjectId.new.to_s }
    let(:article) { build_stubbed(:article) }
    let(:comment) { build_stubbed(:comment) }

    before(:each) do
      sign_in current_user
    end

    before do
      Article.stub :find => article
      article.stub_chain :comments, :find => comment
      comment.stub :like
      comment.stub :save
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user

      post :like, article_id: article_id, comment_id: comment_id
      response.should redirect_to(new_user_session_url)
    end

    it "looks up the comment by id" do
      Article.find.comments.should_receive(:find).with(comment_id)
      post :like, article_id: article_id, comment_id: comment_id
    end

    it "assigns the comment to @comment" do
      post :like, article_id: article_id, comment_id: comment_id
      controller.should assign_to(:comment).with(comment)
    end

    it "likes the comment on behalf of the user" do
      comment.should_receive(:like).with(current_user)
      comment.should_receive(:save)
      post :like, article_id: article_id, comment_id: comment_id
    end

    it "redirects to the article on like success" do
      comment.stub save: true
      post :like, article_id: article_id, comment_id: comment_id

      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "Comment was successfully liked."
    end

    it "redirects to the article on like failure" do
      comment.stub save: false
      post :like, article_id: article_id, comment_id: comment_id
      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "There was an error liking this comment."
    end

    it "redirects to the article on dislike success" do
      comment.stub save: true
      post :dislike, article_id: article_id, comment_id: comment_id

      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "Comment was successfully disliked."
    end

    it "redirects to the article on dislike failure" do
      comment.stub save: false
      post :dislike, article_id: article_id, comment_id: comment_id
      controller.should redirect_to(article_url(article)) and 
        response.request.flash[:notice].should eq "There was an error disliking this comment."
    end

    it "renders the correct template on ajax success" do
      comment.stub save: true
      xhr :post, :like, article_id: article_id, comment_id: comment_id

      controller.should render_template('/articles/comment_votes') 
    end

    it "does nothing on ajax failure" do
      xhr :post, :like, article_id: article_id, comment_id: comment_id

      controller.should_not render_template('/articles/comment_votes') 
    end
  end
end
