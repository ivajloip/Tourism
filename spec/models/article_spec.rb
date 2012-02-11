require 'spec_helper'

describe Article do
  it { should_not allow_mass_assignment_of(:author_id) }
  it { should_not allow_mass_assignment_of(:created_at) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:province) }

  describe "(editing)" do
    let(:article) { build :article }

    it "is editable by its author" do
      article.should be_editable_by article.author
    end

    it "is editable by admins" do
      article.should be_editable_by build(:admin)
    end

    it "is not editable by other users" do
      article.should_not be_editable_by build(:user)
    end

    it "get correct author name" do
      article.author_name.should eq article.author.display_name
    end
  end

  describe "(voting)" do
    let(:article) { build :article }
    let(:reader) { build :user }
    
    it "should get liked votes correct" do
      article.like(reader)
      article.liking_count.should eq 1
    end

    it "should get disliked votes correct" do
      article.dislike(reader)
      article.disliking_count.should eq 1
    end
  end

  describe "(following)" do
    let(:article) { build :article }
    let(:follower) { build :user }

    it "should be able to follow" do
      article.follow(follower)
      article.following_ids.should be_include follower._id
    end

    it "should be able to unfollow" do
      article.follow(follower)
      article.unfollow(follower)
      article.following_ids.should_not be_include follower._id
    end

    it "should get following count correctly" do
      article.follow(follower)
      article.follow(build(:user))
      article.following_count.should eq 2

      article.unfollow(follower)
      article.following_count.should eq 1
    end
  end

  describe "(followers emails)" do
    let(:article) { build :article }
  
    it "gets users emails" do 
      article.followers_emails.should =~ []
      user1 = build :user
      user2 = build :user
      article.follow(user1)
      article.follow(user2)

      article.followers_emails.should =~ [user1.email, user2.email]
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
