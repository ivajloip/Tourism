class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @article.comments.create!(params[:comment])

    @comments = @article.comments.order_by(:name, :asc).page(params[:page]).per(@page_size)

    @url = article_path(@article)

    respond_to do |format|
      format.html { redirect_to @article, :notice => "Comment created!" }
      format.js { render '/articles/comments' }
    end
  end
end
