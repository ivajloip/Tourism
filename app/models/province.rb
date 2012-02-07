class Province
  include Mongoid::Document
  field :key, :type => String

  references_many :articles, :inverse_of => :province

  validates_presence_of :key

  attr_accessible :key

  def name
    I18n.t('province.' + key, :default => key.capitalize)
  end
end
