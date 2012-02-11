require 'spec_helper'

describe ProvincesController do
  describe "GET index" do
    before do 
      Province.stub_chain :all, :page, :per => 'provinces'

      sign_in create(:admin)
    end

    it "paginates all provinces to @provinces" do
      Province.should_receive(:all)

      Province.all.page.should_receive(:per)

      get :index, :page => '1'
      assigns(:provinces).should == 'provinces'
    end

    it "search the correct page for pagination" do
      Province.all.should_receive(:page).with('3')
      get :index, :page => '3'
    end
  end

  describe "GET show" do
    let(:province) { build_stubbed(:province) }
    let(:admin) { create :admin }

    before do
      Province.stub :find => province
    end

    def show_province
      get :show, :id => '42'
    end

    it "redirect to sign_in if not authenticated" do
      show_province

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_in create(:user)
      show_province

      response.should redirect_to('/')
    end

    it "looks up the province by id" do
      sign_in admin
  
      Province.should_receive(:find).with('42')
      show_province
    end

    it "assigns the province to @province" do
      sign_in admin

      show_province
      assigns(:province).should eq province
    end
  end

  describe "POST new" do
    def new_province
      post :new
    end

    it "redirect to sign_in if not authenticated" do
      new_province

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_in create(:user)
      new_province

      response.should redirect_to('/')
    end

    it "assigns the province to @province" do
      province = build_stubbed(:province)
      Province.stub new: province
      sign_in create(:admin)

      new_province

      controller.should assign_to(:province).with(province)
    end
  end


  describe "POST edit" do
    let(:province_id) { BSON::ObjectId.new.to_s }
    let(:province) { build_stubbed(:province) }

    before do
      Province.stub :find => province
    end
    
    def edit_province
      get :edit, :id => province_id
    end

    it "redirect to sign_in if not authenticated" do
      edit_province

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_in create(:user)
      edit_province

      response.should redirect_to('/')
    end

    it "assigns the province to @province" do
      sign_in create(:admin)

      edit_province

      controller.should assign_to(:province).with(province)
    end

    it "looks up the province by id" do
      sign_in create(:admin)

      Province.should_receive(:find).with(province_id)
      edit_province
    end
  end
    
  describe "POST create" do
    let(:admin) { create :admin }
    let(:province) { build_stubbed(:province) }

    before do
      Province.stub new: province
      province.stub :save

      sign_in admin
    end

    def create_province province = {}
      post :create, province
    end

    it "redirect to sign_in if not authenticated" do
      sign_out admin
      create_province

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_out admin
      sign_in create(:user)
      create_province

      response.should redirect_to('/')
    end

    it "assigns the province to @province" do
      create_province

      controller.should assign_to(:province).with(province)
    end

    it "creates a new province with the given attributes" do
      Province.should_receive(:new).with('province-attributes')

      create_province province: 'province-attributes'
    end

    it "attempts to save the province" do
      province.should_receive :save

      create_province
    end

    it "redirects to the province on success" do
      province.stub save: true

      create_province
      controller.should redirect_to(province_url(province)) 
    end

    it "redisplays the province for editing on failure" do
      province.stub save: false
      
      create_province
      controller.should render_template('provinces/new', 'layouts/application')
    end
  end

  describe "PUT update" do
    let(:admin) { create(:admin) }
    let(:province_id) { BSON::ObjectId.new.to_s }
    let(:province) { build_stubbed(:province) }

    before do
      Province.stub find: province
      province.stub :update_attributes

      sign_in admin
    end

    def update_province args = {}
      put(:update, { id: province_id }.merge(args))
    end

    it "redirect to sign_in if not authenticated" do
      sign_out admin
      update_province

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_out admin
      sign_in create(:user)
      update_province

      response.should redirect_to('/')
    end

    it "assigns the province to @province" do
      update_province
      controller.should assign_to(:province).with(province)
    end

    it "looks up the province by id" do
      Province.should_receive(:find).with(province_id)
      update_province
    end

    it "attempts to update the province with params[:province]" do
      province.should_receive(:update_attributes).with('province-attributes')
      update_province province: 'province-attributes'
    end

    it "redirects to the province on success" do
      province.stub update_attributes: true
      update_province
      controller.should redirect_to province
    end

    it "redisplays the form on failure" do
      province.stub update_attributes: false
      update_province
      controller.should render_template :edit
    end
  end

  describe "DELETE destroy" do
    let(:admin) { create(:admin) }
    let(:province_id) { BSON::ObjectId.new.to_s }
    let(:province) { build_stubbed(:province) }

    before do
      Province.stub find: province
      province.stub :destroy

      sign_in admin
    end

    def delete_province
      delete :destroy,  id: province_id
    end

    it "redirect to sign_in if not authenticated" do
      sign_out admin
      delete_province

      response.should redirect_to(new_user_session_url)
    end

    it "redirect to root if authenticated but not admin" do
      sign_out admin
      sign_in create(:user)
      delete_province

      response.should redirect_to('/')
    end

    it "looks up the province by id" do
      Province.should_receive(:find).with(province_id)
      delete_province
    end

    it "attempts to update the province with params[:province]" do
      province.should_receive(:destroy)
      delete_province
    end

    it "redirects to the provinces on success" do
      delete_province
      controller.should redirect_to provinces_url
    end
  end
end
