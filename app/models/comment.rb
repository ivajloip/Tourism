class Comment
  include Mongoid::Document
  field :name, :type => String
  field :content, :type => String
  embedded_in :article, :inverse_of => :comments

  validates_presence_of :name
#  referenced_in :user
end
