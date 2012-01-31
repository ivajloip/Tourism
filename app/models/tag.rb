class Tag
  include Mongoid::Document

  field :key, :type => String

  references_and_referenced_in_many :articles, :inverse_of => :tags

  def name
    I18n.t('tags.' + key)
  end
end
