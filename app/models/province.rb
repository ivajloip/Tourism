class Province
  include Mongoid::Document
  include Hidable

  field :key, :type => String

  references_many :articles, :inverse_of => :province

  validates_presence_of :key

  attr_accessible :key, :active

  def name
    I18n.t('provinces.' + key, :default => key.capitalize)
  end
end
