class Article
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, :type => String
  field :content, :type => String
  embeds_many :comments
  references_and_referenced_in_many :tags, :inverse_of => :articles
  references_and_referenced_in_many :following, :class_name => 'User', :inverse_of => :follows
  references_and_referenced_in_many :liking, :class_name => 'User', :inverse_of => :likes
  references_and_referenced_in_many :disliking, :class_name => 'User', :inverse_of => :dislikes
  referenced_in :author, :class_name => 'User'
  referenced_in :province

  validates_presence_of :title
  validates_presence_of :content 
  validates_presence_of :province

  def liking_count
    liking.blank? ? 0 : liking.count
  end

  def disliking_count
    disliking.blank? ? 0 : disliking.count
  end

  def following_count
    following.blank? ? 0 : following.count
  end
end
