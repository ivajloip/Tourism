# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false

  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end
   
  config.before(:each) do
    DatabaseCleaner[:mongoid].start
  end
   
  config.after(:each) do
    DatabaseCleaner[:mongoid].clean
  end

  config.include Support::ControllerHelpers, :type => :controller
  config.include Factory::Syntax::Methods
  config.include Devise::TestHelpers, :type => :controller
  config.include EmailSpec::Helpers, type: :mailer
  config.include EmailSpec::Matchers, type: :mailer
end
