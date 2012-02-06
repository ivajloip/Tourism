class Article
  include Mongoid::Document
  include Mongoid::Timestamps
  include Votable

  field :title, :type => String
  field :content, :type => String
  references_and_referenced_in_many :tags, :inverse_of => :articles
  references_and_referenced_in_many :following, :class_name => 'User', :inverse_of => :follows
  references_and_referenced_in_many :liking, :class_name => 'User', :inverse_of => :likes
  references_and_referenced_in_many :disliking, :class_name => 'User', :inverse_of => :dislikes
  referenced_in :author, :class_name => 'User'
  referenced_in :province
  embeds_many :comments

  validates_presence_of :title
  validates_presence_of :content 
  validates_presence_of :province

  attr_accessible :title, :content, :province, :tags

  def initialize *args
    @liking = []
    @disliking = []
    super
  end

  def editable_by?(user)
    self.author == user or user.try(:admin?)
  end

  def author_name
    author.display_name
  end

  def like(user)
    disliking_ids.delete(user._id)

    unless liking_ids.include? user._id
      liking_ids << user._id
    end
  end

  def dislike(user)
    liking_ids.delete(user._id)

    unless disliking_ids.include? user._id
      disliking_ids << user._id
    end
  end

  def follow(user)
    unless following_ids.include? user._id
      following_ids << user._id
    end
  end

  def unfollow(user)
    following_ids.delete(user._id)
  end

  def following_count
    following_ids.blank? ? 0 : following_ids.count
  end


  def followers_emails
    following.map(&:email)
  end
end
