class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :only => [:edit, :update, :destroy] do
    verify_edit_permissions User.find(params[:id])
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all.page(params[:page]).per(@page_size)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    if params[:user].try(:[], :password).blank?
      params[:user].try(:delete, :password_confirmation)
      params[:user].try(:delete, :password)
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  # POST /users/1/follow
  # POST /users/1/follow.json
  def follow
    add_opinion('User was successfully followed.', 'There was an error following this user.') do |user|
      user.follow(current_user)
    end
  end


  # POST /articles/1/unfollow
  # POST /articles/1/unfollow.json
  def unfollow
    add_opinion('User was successfully unfollowed.', 'There was an error unfollowing this user.') do |user|
      user.unfollow(current_user)
    end
  end

private  
  def add_opinion success_message, failure_message
    super(success_message, failure_message) do 
      @user = User.find(params[:id])
      yield @user

      [@user, @user]
    end
  end
end
