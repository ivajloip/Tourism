class Article
  include Mongoid::Document
  include Mongoid::Timestamps
  include Votable
  include Followable
  include Hidable

  field :title, :type => String
  field :content, :type => String

  references_and_referenced_in_many :tags, :inverse_of => :articles
  references_and_referenced_in_many :following, :class_name => 'User', :inverse_of => :follows_articles
  references_and_referenced_in_many :liking, :class_name => 'User', :inverse_of => :likes
  references_and_referenced_in_many :disliking, :class_name => 'User', :inverse_of => :dislikes
  referenced_in :author, :class_name => 'User'
  referenced_in :province
  embeds_many :comments

  validates_presence_of :title
  validates_presence_of :content 
  validates_presence_of :province

  attr_accessible :title, :content, :province_id, :tag_ids, :active

  def editable_by?(user)
    self.author == user or user.try(:admin?)
  end

  def author_name
    author.display_name
  end

  def all_visible
    super do 
      any_of({ :active => true }, { :author_id => current_user.try(:_id) })
    end
  end
end
