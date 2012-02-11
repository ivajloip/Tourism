require 'spec_helper'

describe Province do
  it { should validate_presence_of(:key) }

  describe "(name)" do
    it "can provide name" do
      province = build :province
      province.name.should eq 'Province'
    end

# TODO: fix this to something less specific
    it "name is localized" do
      province = build(:province, :key => 'sofia')
      province.name.should eq I18n.t('provinces.sofia')
    end
  end

  describe "(activate/deactivate)" do
    it "should be constructed active by default" do
      article = build :article

      article.should be_active
    end

    it "should be able to deactivate it" do
      article = build :article, :active => true
      article.deactivate

      article.should_not be_active
    end

    it "should be able to activate it" do
      article = build :article, :active => false
      article.activate

      article.should be_active
    end
  end
end
