class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :search]

  before_filter :only => [:edit, :update, :destroy] do
    verify_edit_permissions find_article
  end

  # GET /articles
  # GET /articles.json
  def index
    visible_articles = Article.all_visible(current_user)
    @articles = visible_articles.order_by(:created_at, :desc).page(params[:page]).per(@page_size)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = find_article
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
    @article = find_article
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(params[:article])
    @article.author = current_user

    if @article.save
      respond_to do |format|
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render json: @article, status: :created, location: @article }
      end

      to = current_user.followers_emails
      unless to.blank?
        Notifier.article_added(current_user, @article).deliver
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.json
  def update
    @article = find_article

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
    @article = find_article
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :ok }
    end
  end

  # POST /articles/1/like
  # POST /articles/1/likes.json
  def like
    add_opinion(t('articles.like.success'), t('articles.like.fail')) do |article|
      article.like(current_user)
    end
  end

  # POST /articles/1/dislike
  # POST /articles/1/dislikes.json
  def dislike
    add_opinion(t('articles.dislike.success'), t('articles.dislike.fail')) do |article|
      article.dislike(current_user)
    end
  end

  # POST /articles/1/follow
  # POST /articles/1/follow.json
  def follow
    add_opinion(t('articles.follow.success'), t('articles.follow.fail')) do |article|
      article.follow(current_user)
    end
  end


  # POST /articles/1/unfollow
  # POST /articles/1/unfollow.json
  def unfollow
    add_opinion(t('articles.unfollow.success'), t('articles.unfollow.fail')) do |article|
      article.unfollow(current_user)
    end
  end

  def search
    query = synthesize_query

    logger.debug("------#{query}------")

    visible_articles = Article.all_visible(current_user)
    @articles = visible_articles.where(query).order_by(:created_at, :desc).page(params[:page]).per(@page_size)
    @article = Article.new
    @authors = User.all_visible(current_user)

    respond_to do |format|
      format.html # search.html.erb
      format.json { render json: @articles }
    end
  end

private
  def find_article
    Article.find(params[:id])
  end

  def add_opinion success_message, failure_message
    super(success_message, failure_message) do 
      @article = find_article
      yield @article

      [@article, @article]
    end
  end

  def synthesize_query
    unless params[:query] 
      return nil
    end

    result = {}

    form_param = :article

    result[:created_at] = created_at_limits

    result[:author_id] = params[form_param]['author_id']

    result[:tag_ids.all] = params[form_param]['tag_ids']

    unless params[form_param]['title'].blank?
      result[:title] = Regexp.new(params[form_param]['title'])
    end

    result.merge(synthesize_mandatory_fields_query).reject { |key, value| value.blank? }
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
    exceptions = ['tag_ids', 'title']
    fields = Article.attr_accessible[:default] - exceptions

    params[:article].select { |key, value| fields.include?(key) }
  end
end
