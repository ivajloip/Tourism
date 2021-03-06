require 'spec_helper'

describe User do
  it { should_not allow_mass_assignment_of(:admin) }
  it { should_not allow_mass_assignment_of(:created_at) }

  it { should validate_presence_of(:display_name) }
  it { should validate_presence_of(:password) }

  describe "(following)" do
    let(:article) { build :article }
    let(:follower) { build :user }

    it "Should be able to follow" do
      article.follow(follower)
      article.following_ids.should be_include follower._id
    end

    it "Should be able to unfollow" do
      article.follow(follower)
      article.unfollow(follower)
      article.following_ids.should_not be_include follower._id
    end

    it "Should get following count correctly" do
      article.follow(follower)
      article.follow(build(:user))
      article.following_count.should eq 2

      article.unfollow(follower)
      article.following_count.should eq 1
    end

    it "gets users emails" do 
      article.followers_emails.should =~ []
      follower2 = build :user
      article.follow(follower)
      article.follow(follower2)

      article.followers_emails.should =~ [follower.email, follower2.email]
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
