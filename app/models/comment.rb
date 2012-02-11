class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Votable
  include Hidable

  field :content, :type => String
  embedded_in :article, :inverse_of => :comments

  referenced_in :author, :class_name => 'User'
  references_and_referenced_in_many :liking, :class_name => 'User', :inverse_of => :likes_comments
  references_and_referenced_in_many :disliking, :class_name => 'User', :inverse_of => :dislikes_comments

  attr_accessible :content

  validates_presence_of :content

  def editable_by?(user)
    self.author == user or user.try(:admin?)
  end

  def author_name
    author.display_name
  end
end
