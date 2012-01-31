class Province
  include Mongoid::Document
  field :name, :type => String

  references_many :articles, :inverse_of => :province

  validates_presence_of :name
end
