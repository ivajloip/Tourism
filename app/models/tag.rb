class Tag
  include Mongoid::Document
  include Hidable

  field :key, :type => String

  references_and_referenced_in_many :articles, :inverse_of => :tags

  validates_presence_of :key

  attr_accessible :key, :active

  def name
    I18n.t('tags.' + key, :default => key.capitalize)
  end
end
