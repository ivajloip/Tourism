class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @article = Article.find(params[:article_id])

    @comment = @article.comments.new(params[:comment])

    @comment.author = current_user

    @comments = @article.comments.order_by(:name, :asc).page(params[:page]).per(@page_size)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @article, :notice => "Comment created!" }
        format.json { render json: @article, status: :created, location: @article }
        format.js { render '/articles/comments' }
      else
        format.html { redirect_to @article }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end


  # POST /articles/1/comments/1/like
  # POST /articles/1/comments/1/likes.json
  def like
    @comment = Article.find(params[:article_id]).comments.find(params[:comment_id])

    @comment.like(current_user)

    @comment.save

    respond_to do |format|
      format.html { redirect_to @comment, notice: 'Article was successfully liked.' }
      format.json { head :ok }
      format.js { render '/articles/comment_votes' }
    end
  end


  # POST /articles/1/comments/1/dislike
  # POST /articles/1/comments/1/dislikes.json
  def dislike
    logger.debug params
    @comment = Article.find(params[:article_id]).comments.find(params[:comment_id])

    @comment.dislike(current_user)

    @comment.save

    respond_to do |format|
      format.html { redirect_to @comment, notice: 'Article was successfully disliked.' }
      format.json { head :ok }
      format.js { render '/articles/comment_votes' }
    end
  end
end
