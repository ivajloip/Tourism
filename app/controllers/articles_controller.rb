class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :only => [:edit, :update, :destroy] do
    verify_edit_permissions Article.find(params[:id])
  end

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.order_by(:created_at, :desc).page(params[:page]).per(@page_size)

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
    add_opinion('Article was successfully liked.', 'There was an error liking this article.') do |article|
      article.like(current_user)
    end
  end

  # POST /articles/1/dislike
  # POST /articles/1/dislikes.json
  def dislike
    add_opinion('Article was successfully disliked.', 'There was an error disliking this article.') do |article|
      article.dislike(current_user)
    end
  end

  # POST /articles/1/follow
  # POST /articles/1/follow.json
  def follow
    add_opinion('Article was successfully followed.', 'There was an error following this article.') do |article|
      article.follow(current_user)
    end
  end


  # POST /articles/1/unfollow
  # POST /articles/1/unfollow.json
  def unfollow
    add_opinion('Article was successfully unfollowed.', 'There was an error unfollowing this article.') do |article|
      article.unfollow(current_user)
    end
  end

  def search
    query = synthesize_query

    logger.debug("------#{query}------")

    @authors = User.all
    @article = Article.new
    @articles = Article.where(query).order_by(:created_at, :desc).page(params[:page]).per(@page_size)

    respond_to do |format|
      format.html # search.html.erb
      format.json { render json: @articles }
    end
  end

private
  def add_opinion success_message, failure_message
    @article = Article.find(params[:id])

    yield @article

    if @article.save
      respond_to do |format|
        format.html { redirect_to @article, notice: success_message }
        format.json { head :ok }
        format.js { render '/articles/votes' }
      end
    else 
      respond_to do |format|
        format.html { redirect_to @article, notice: failure_message }
        format.json { render json: comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def synthesize_query
    unless params[:query] 
      return nil
    end

    result = {}

    logger.debug("-----------#{params}---------")

    form_param = :article

    result[:created_at] = created_at_limits

    result[:author_id] = params[form_param]['author_id']

    result[:tag_ids.all] = params[form_param]['tag_ids']

    result.merge(synthesize_mandatory_fields_query).select { |key, value| not value.blank? }
  end

  def created_at_limits
    result = {}

    result['$gte'] = time_selected('start_date') 
    result['$lt'] = time_selected('end_date') 

    result.reject { |key,value| value.blank? }
  end

  def time_selected prefix
    date = (1..3).map { |i| params['query'][prefix + "(#{i}i)"] }

    date.none?(&:blank?) ? Time.new(*date) : nil
  end

  def synthesize_mandatory_fields_query
    exceptions = ['tag_ids']
    fields = Article.accessible_attributes.to_a - exceptions
    fields += fields.map { |field| field + '_id' } + fields.map { |field| field + '_ids' }

    # TODO: Make this the other way around -> from fields take some
    params[:article].select { |key, value| fields.include?(key) }
  end
end
