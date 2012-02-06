require 'spec_helper'

describe Comment do
  it { should_not allow_mass_assignment_of(:author_id) }
  it { should_not allow_mass_assignment_of(:article_id) }

  it { should validate_presence_of(:content) }

  describe "(editing)" do
    let(:comment) { build :comment }

    it "is editable by its author" do
      comment.should be_editable_by comment.author
    end

    it "is editable by admins" do
      comment.should be_editable_by build(:admin)
    end

    it "is not editable by other users" do
      comment.should_not be_editable_by build(:user)
    end

    it "Get correct author name" do
      comment.author_name.should eq comment.author.display_name
    end
  end

  describe "(voting)" do
    let(:comment) { build :comment }
    let(:reader) { build :user }
    
    it "Should get liked votes correct" do
      comment.like(reader)
      comment.liking_count.should eq 1
    end

    it "Should get disliked votes correct" do
      comment.dislike(reader)
      comment.disliking_count.should eq 1
    end

    it "Should allow liking only once" do
      comment.like(reader)
      comment.like(reader)
      comment.liking_count.should eq 1
    end

    it "Should allow disliking only once" do
      comment.dislike(reader)
      comment.dislike(reader)
      comment.disliking_count.should eq 1
    end

    it "Dislike after like" do
      comment.like(reader)
      comment.dislike(reader)
      comment.disliking_count.should eq 1
      comment.liking_count.should eq 0
    end

    it "Like after dislike" do
      comment.dislike(reader)
      comment.like(reader)
      comment.liking_count.should eq 1
      comment.disliking_count.should eq 0
    end
  end
end
