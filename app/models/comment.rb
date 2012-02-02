class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, :type => String
  embedded_in :article, :inverse_of => :comments

  references_and_referenced_in_many :liking, :class_name => 'User', :inverse_of => :likes_comments
  references_and_referenced_in_many :disliking, :class_name => 'User', :inverse_of => :dislikes_comments
  referenced_in :author, :class_name => 'User'

  def liking_count
    liking.blank? ? 0 : liking.count
  end

  def disliking_count
    disliking.blank? ? 0 : disliking.count
  end

#  referenced_in :user
end
