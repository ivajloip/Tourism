source 'http://rubygems.org'

gem 'rails', '3.1.3'

#gem 'sqlite3'
gem 'therubyracer', :platforms => :ruby
gem 'execjs'
gem 'bson_ext'
gem 'mongoid', '2.4.0'
gem 'mongoid-paperclip', :require => 'mongoid_paperclip'
gem 'carrierwave'
gem 'mini_magick'
gem 'kaminari'

gem 'devise'

gem "recaptcha", :require => "recaptcha/rails"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'email_spec'

  gem 'cucumber-rails'
  gem 'capybara'
end
