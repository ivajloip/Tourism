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
      province.name.should eq I18n.t('province.sofia')
    end
  end
end
