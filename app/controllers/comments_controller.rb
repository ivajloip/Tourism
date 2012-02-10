class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @article = find_article

    @comment = @article.comments.new(params[:comment])

    @comment.author = current_user

    @comments = @article.comments.order_by(:name, :asc).page(params[:page]).per(@page_size)

    if @comment.save
      respond_to do |format|
        format.html { redirect_to @article, :notice => "Comment created!" }
        format.json { render json: @article, status: :created, location: @article }
        format.js { render '/articles/comments' }
      end

      to = @comment.article.followers_emails
      unless to.blank?
        Notifier.new_comment(@comment).deliver
      end
    else
      respond_to do |format|
        format.html { redirect_to @article }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end


  # POST /articles/1/comments/1/like
  # POST /articles/1/comments/1/likes.json
  def like
    add_opinion('Comment was successfully liked.', 'There was an error liking this comment.') do |comment|
      comment.like(current_user)
    end
  end


  # POST /articles/1/comments/1/dislike
  # POST /articles/1/comments/1/dislikes.json
  def dislike
    add_opinion('Comment was successfully disliked.', 'There was an error disliking this comment.') do |comment|
      comment.dislike(current_user)
    end
  end

  private

  def add_opinion success_message, failure_message
    super(success_message, failure_message) do 
      @article = find_article
      @comment = @article.comments.find(params[:comment_id])
      yield @comment

      [@comment, @article]
    end
  end

  def vote success_message, failure_message
    @article = find_article
    @comment = @article.comments.find(params[:comment_id])

    yield @comment

    if @comment.save
      respond_to do |format|
        format.html { redirect_to @article, notice: success_message }
        format.json { head :ok }
        format.js { render '/articles/comment_votes' }
      end
    else 
      respond_to do |format|
        format.html { redirect_to @article, notice: failure_message }
        format.json { render json: comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def find_article
    Article.find(params[:article_id])
  end
end
