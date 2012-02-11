require 'spec_helper'

describe TagsController do
  describe "GET index" do
    before do 
      Tag.stub_chain :all, :page, :per => 'tags'

      sign_in create(:admin)
    end

    it "paginates all tags to @tags" do
      Tag.should_receive(:all)

      Tag.all.page.should_receive(:per)

      get :index, :page => '1'
      assigns(:tags).should == 'tags'
    end

    it "search the correct page for pagination" do
      Tag.all.should_receive(:page).with('3')
      get :index, :page => '3'
    end
  end

  describe "GET show" do
    let(:tag) { build_stubbed(:tag) }
    let(:admin) { create :admin }

    before do
      Tag.stub :find => tag
    end

    def show_tag
      get :show, :id => '42'
    end

    it "redirect to sign_in if not authenticated" do
      show_tag
      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_in create(:user)

      show_tag
      response.should redirect_to('/')
    end

    it "looks up the tag by id" do
      sign_in admin
      Tag.should_receive(:find).with('42')
      show_tag
    end

    it "assigns the tag to @tag" do
      sign_in admin
      show_tag
      assigns(:tag).should eq tag
    end
  end


  describe "POST new" do
    def new_tag
      post :new
    end

    it "redirect to sign_in if not authenticated" do
      new_tag

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_in create(:user)
      new_tag

      response.should redirect_to('/')
    end

    it "assigns the tag to @tag" do
      tag = build_stubbed(:tag)
      Tag.stub new: tag
      sign_in create(:admin)

      new_tag

      controller.should assign_to(:tag).with(tag)
    end
  end


  describe "POST edit" do
    let(:tag_id) { BSON::ObjectId.new.to_s }
    let(:tag) { build_stubbed(:tag) }

    before do
      Tag.stub :find => tag
    end
    
    def edit_tag
      get :edit, :id => tag_id
    end

    it "redirect to sign_in if not authenticated" do
      edit_tag

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_in create(:user)
      edit_tag

      response.should redirect_to('/')
    end

    it "assigns the tag to @tag" do
      sign_in create(:admin)

      edit_tag

      controller.should assign_to(:tag).with(tag)
    end

    it "looks up the tag by id" do
      sign_in create(:admin)

      Tag.should_receive(:find).with(tag_id)
      edit_tag
    end
  end
    
  describe "POST create" do
    let(:admin) { create :admin }
    let(:tag) { build_stubbed(:tag) }

    before do
      Tag.stub new: tag
      tag.stub :save

      sign_in admin
    end

    def create_tag tag = {}
      post :create, tag
    end

    it "redirect to sign_in if not authenticated" do
      sign_out admin
      create_tag

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_out admin
      sign_in create(:user)
      create_tag

      response.should redirect_to('/')
    end

    it "assigns the tag to @tag" do
      create_tag

      controller.should assign_to(:tag).with(tag)
    end

    it "creates a new tag with the given attributes" do
      Tag.should_receive(:new).with('tag-attributes')

      create_tag tag: 'tag-attributes'
    end

    it "attempts to save the tag" do
      tag.should_receive :save

      create_tag
    end

    it "redirects to the tag on success" do
      tag.stub save: true

      create_tag
      controller.should redirect_to(tag_url(tag)) 
    end

    it "redisplays the tag for editing on failure" do
      tag.stub save: false
      
      create_tag
      controller.should render_template('new', 'layouts/application')
    end
  end

  describe "PUT update" do
    let(:admin) { create(:admin) }
    let(:tag_id) { BSON::ObjectId.new.to_s }
    let(:tag) { build_stubbed(:tag) }

    before do
      Tag.stub find: tag
      tag.stub :update_attributes

      sign_in admin
    end

    def update_tag args = {}
      put(:update, { id: tag_id }.merge(args))
    end

    it "redirect to sign_in if not authenticated" do
      sign_out admin
      update_tag

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_out admin
      sign_in create(:user)
      update_tag

      response.should redirect_to('/')
    end

    it "assigns the tag to @tag" do
      update_tag
      controller.should assign_to(:tag).with(tag)
    end

    it "looks up the tag by id" do
      Tag.should_receive(:find).with(tag_id)
      update_tag
    end

    it "attempts to update the tag with params[:tag]" do
      tag.should_receive(:update_attributes).with('tag-attributes')
      update_tag tag: 'tag-attributes'
    end

    it "redirects to the tag on success" do
      tag.stub update_attributes: true
      update_tag
      controller.should redirect_to tag
    end

    it "redisplays the form on failure" do
      tag.stub update_attributes: false
      update_tag
      controller.should render_template :edit
    end
  end

  describe "DELETE destroy" do
    let(:admin) { create(:admin) }
    let(:tag_id) { BSON::ObjectId.new.to_s }
    let(:tag) { build_stubbed(:tag) }

    before do
      Tag.stub find: tag
      tag.stub :destroy

      sign_in admin
    end

    def delete_tag
      delete :destroy,  id: tag_id
    end

    it "redirect to sign_in if not authenticated" do
      sign_out admin
      delete_tag

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_out admin
      sign_in create(:user)
      delete_tag

      response.should redirect_to('/')
    end

    it "looks up the tag by id" do
      Tag.should_receive(:find).with(tag_id)
      delete_tag
    end

    it "attempts to update the tag with params[:tag]" do
      tag.should_receive(:destroy)
      delete_tag
    end

    it "redirects to the tags on success" do
      delete_tag
      controller.should redirect_to tags_url
    end
  end
end
