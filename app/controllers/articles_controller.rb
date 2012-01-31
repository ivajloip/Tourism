class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :only => [:edit, :updated, :destroy] do
    verify_edit_permissions Article.find(params[:id])
  end

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.order_by(:created_at, :desc).page(params[:page]).per(2)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = Article.find(params[:id])
    @comments = @article.comments.order_by(:name, :asc).page(params[:page]).per(@page_size)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.json
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(params[:article])
    @article.author = current_user

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render json: @article, status: :created, location: @article }
      else
        format.html { render action: "new" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.json
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :ok }
    end
  end


  # POST /articles/1/like
  # POST /articles/1/likes.json
  def like
    @article = Article.find(params[:id])

    liking_ids = @article.liking_ids
    disliking_ids = @article.disliking_ids

    disliking_ids.delete(current_user._id)

    unless liking_ids.include? current_user._id
      liking_ids << current_user._id
    end

    @article.save

    respond_to do |format|
      format.html { redirect_to @article, notice: 'Article was successfully liked.' }
      format.json { head :ok }
      format.js { render '/articles/votes' }
    end
  end


  # POST /articles/1/dislike
  # POST /articles/1/dislikes.json
  def dislike
    @article = Article.find(params[:id])
    liking_ids = @article.liking_ids
    disliking_ids = @article.disliking_ids

    liking_ids.delete(current_user._id)

    logger.debug "liking_ids contrains current_user? #{liking_ids.include? current_user._id}"

    unless disliking_ids.include? current_user._id
      disliking_ids << current_user._id
    end

    @article.save

    respond_to do |format|
      format.html { redirect_to @article, notice: 'Article was successfully disliked.' }
      format.json { head :ok }
      format.js { render '/articles/votes' }
    end
  end


  # POST /articles/1/follow
  # POST /articles/1/follow.json
  def follow
    @article = Article.find(params[:id])
    following = @article.following

    unless following.include? current_user
      following << current_user
    end

    @article.save

    respond_to do |format|
      format.html { redirect_to @article, notice: 'Article was successfully followed.' }
      format.json { head :ok }
      format.js { render '/articles/votes' }
    end
  end


  # POST /articles/1/unfollow
  # POST /articles/1/unfollow.json
  def unfollow
    @article = Article.find(params[:id])
    following_ids = @article.following_ids

    following_ids.delete(current_user._id)

    @article.save

    respond_to do |format|
      format.html { redirect_to @article, notice: 'Article was successfully unfollowed.' }
      format.json { head :ok }
      format.js { render '/articles/votes' }
    end
  end

  def find
    
  end
end
