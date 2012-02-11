module Support
  module ControllerHelpers
    module ClassMethods
    end

    def self.included(example_group)
      example_group.extend ClassMethods
    end
  end
end
