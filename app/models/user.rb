class User
  include Mongoid::Document
  include Mongoid::Paperclip

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  field :display_name
  field :admin

  references_many :articles, :inverse_of => :author
  references_and_referenced_in_many :follows, :class_name => 'User', :inverse_of => :following
  references_and_referenced_in_many :likes, :class_name => 'User', :inverse_of => :liking
  references_and_referenced_in_many :dislikes, :class_name => 'User', :inverse_of => :disliking
  references_and_referenced_in_many :likes_comments, :class_name => 'User', :inverse_of => :liking
  references_and_referenced_in_many :dislikes_comments, :class_name => 'User', :inverse_of => :disliking

  attr_accessible :display_name, :email, :avatar

  has_mongoid_attached_file :avatar, 
    :default_url => '/system/:attachment/no_avatar.png',
    :default_style => :original,
    :styles => {
        :original => ['1920x1680>', :png],
        :small    => ['128x128#',   :png],
        :very_small => ['60x60#', :png],
        :medium   => ['256x256#',    :png],
        :large    => ['768x768>',   :png],
    }

  validates_confirmation_of :password
  validates_presence_of :display_name
end
