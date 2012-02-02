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

    liking_ids = @comment.liking_ids
    disliking_ids = @comment.disliking_ids

    disliking_ids.delete(current_user._id)

    unless liking_ids.include? current_user._id
      liking_ids << current_user._id
    end

    @comment.save

    @article = @comment

    respond_to do |format|
      format.html { redirect_to @comment, notice: 'Article was successfully liked.' }
      format.json { head :ok }
      format.js { render '/articles/votes' }
    end
  end


  # POST /articles/1/comments/1/dislike
  # POST /articles/1/comments/1/dislikes.json
  def dislike
    logger.debug params
    @comment = Article.find(params[:article_id]).comments.find(params[:comment_id])

    liking_ids = @comment.liking_ids
    disliking_ids = @comment.disliking_ids

    liking_ids.delete(current_user._id)

    unless disliking_ids.include? current_user._id
      disliking_ids << current_user._id
    end

    @comment.save

    @article = @comment

    respond_to do |format|
      format.html { redirect_to @comment, notice: 'Article was successfully disliked.' }
      format.json { head :ok }
      format.js { render '/articles/votes' }
    end
  end
end
