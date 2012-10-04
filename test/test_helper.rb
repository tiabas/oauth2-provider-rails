ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def login_user(user)
    @request.session[:user_id] = user.id
  end

  def self.create_dummy_user
    User.create!(
      :first_name => 'smart',
      :last_name => 'kid',
      :email => 'tiabas@creative.me',
      :password => 'letmein'
    )
  end

  def create_dummy_user
    self.class.create_dummy_user
  end

  def self.create_dummy_client_app
    ClientApplication.create!(
      :name => 'dummy app',
      :website => 'https://example.com',
      :description => 'a dummy app for testing OAuth2',
      :client_type => 1,
      :redirect_uri => 'https://example.com/oauth2/cb'
      :terms_of_service => '1'
    )
  end 

  def create_dummy_client_app
    self.class.create_dummy_client_app
  end
end
