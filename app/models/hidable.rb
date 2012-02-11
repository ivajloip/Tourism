module Hidable
  extend ActiveSupport::Concern

  included do
    field :active, :type => Boolean, :default => true
  end

  module InstanceMethods
    def active?
      active
    end
  
    def activate
      self.active = true
    end

    def deactivate
      self.active = false
    end
  end

  module ClassMethods
    def all_visible(user)
      if user.try(:admin?)
        all
      elsif block_given?
        yield
      else
        where(:active => true).all
      end
    end
  end
end
