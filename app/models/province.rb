class Province
  include Mongoid::Document
  field :name, :type => String

  references_many :articles

  validates_presence_of :name
end
