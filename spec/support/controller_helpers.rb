module Support
  module ControllerHelpers
    module ClassMethods
      def login(user)
        request.env['warden'] = mock(Warden,
            :authenticate => mock_user,
            :authenticate! => mock_user)
      end

      def mock_user(type, stubs={})
        mock_model(type, stubs).as_null_object
      end

      def log_in_as(role)
        attributes = case role
          when :reader then {:admin => false}
          when :admin then {:admin => true}
          else raise "Unknown role: #{role}"
        end

        let(:current_user) { FactoryGirl.build(:user, attributes) }

#        before do
#          controller.stub :current_user => FactoryGirl.build(:user, attributes)
#          sign_in controller.current_user
#        end

        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:user]
#          sign_in current_user
#          login(current_user)
        end
      end

      def log_out
        let(:current_user) { nil }
        before { controller.stub current_user: nil }
      end
    end

    RSpec::Matchers.define :deny_access do
      match do |response|
        response.request.flash[:error].present? and response.redirect_url == 'http://test.host/'
      end

      failure_message_for_should { |response| "expected action to deny access" }
    end

    def self.included(example_group)
      example_group.extend ClassMethods
    end
  end
end
