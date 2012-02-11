require 'spec_helper'

describe UsersController do
  describe "GET index" do
    before do 
      User.stub_chain :all, :page, :per => 'users'
    end

    it "paginates all users to @users" do
      User.should_receive(:all)

      User.all.page.should_receive(:per)

      get :index, :page => '1'
      assigns(:users).should == 'users'
    end

    it "search the correct page for pagination" do
      User.all.should_receive(:page).with('3')
      get :index, :page => '3'
    end
  end

  describe "GET show" do
    let(:user) { build_stubbed(:user) }

    before do
      User.stub :find => user
    end

    it "looks up the user by id" do
      User.should_receive(:find).with('42')
      get :show, :id => '42'
    end

    it "assigns the user to @user" do
      get :show, :id => '42'
      assigns(:user).should eq user
    end
  end

  describe "POST edit" do
    let(:current_user) { create(:user) }
    let(:user_id) { BSON::ObjectId.new.to_s }
    let(:user) { build_stubbed(:user) }

    before do
      User.stub :find => user
      user.stub editable_by?: true

      sign_in current_user
    end
    
    def edit_user
      get :edit, :id => user_id
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user
      edit_user

      response.should redirect_to(new_user_session_url)
    end

    it "denies access to users who cannot edit the user" do
      user.should_receive(:editable_by?).and_return(false)
      edit_user
      controller.should redirect_to user_url(user)
    end

    it "assigns the user to @user" do
      edit_user
      controller.should assign_to(:user).with(user)
    end

    it "looks up the user by id" do
      User.should_receive(:find).with(user_id)
      edit_user
    end
  end

  describe "PUT update" do
    let(:current_user) { create(:user) }
    let(:user_id) { BSON::ObjectId.new.to_s }
    let(:user) { build_stubbed(:user) }

    before do
      User.stub find: user
      user.stub :update_attributes
      user.stub editable_by?: true

      sign_in current_user
    end

    def update_user args = {}
      put(:update, { id: user_id }.merge(args))
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user
      update_user

      response.should redirect_to(new_user_session_url)
    end

    it "denies access to users who cannot edit the user" do
      user.should_receive(:editable_by?).and_return(false)
      update_user
      controller.should redirect_to user_url(user)
    end

    it "assigns the user to @user" do
      update_user
      controller.should assign_to(:user).with(user)
    end

    it "looks up the user by id" do
      User.should_receive(:find).with(user_id)
      update_user
    end

    it "attempts to update the user with params[:user]" do
      user_params = {'display_name' => 'foo'}
      user.should_receive(:update_attributes).with(user_params)
      update_user user: user_params
    end

    it "redirects to the user on success" do
      user.stub update_attributes: true
      update_user
      controller.should redirect_to user
    end

    it "redisplays the form on failure" do
      user.stub update_attributes: false
      update_user
      controller.should render_template :edit
    end
  end

  describe "DELETE destroy" do
    let(:current_user) { create(:user) }
    let(:user_id) { BSON::ObjectId.new.to_s }
    let(:user) { build_stubbed(:user) }

    before do
      User.stub find: user
      user.stub :editable_by? => true
      user.stub :destroy

      sign_in current_user
    end

    def delete_user
      delete :destroy, id: user_id
    end

    it "redirect to sign_in if not authenticated" do
      sign_out current_user
      delete_user

      response.should redirect_to(new_user_session_url)
    end

    it "denies access to users who cannot edit the user" do
      user.should_receive(:editable_by?).and_return(false)
      delete_user
      controller.should redirect_to user_url(user)
    end

    it "looks up the user by id" do
      User.should_receive(:find).with(user_id)
      delete_user
    end

    it "attempts to update the user with params[:user]" do
      user.should_receive(:destroy)
      delete_user
    end

    it "redirects to the users on success" do
      delete_user
      controller.should redirect_to users_url
    end
  end
end
