require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase

  def setup
    @client_app = create_dummy_client_app
    @user = create_dummy_user
  end

  def test_should_create_access_token_with_user_id
    token = AccessToken.generate_token(
      :client_application => @client_app,
      :user => @user)
    assert_equal @user.id, token.user_id
    assert_equal @client_app.id, token.client_application_id
  end

  def test_should_create_access_token_with_user_id
    token = AccessToken.generate_token(:client_application => @client_app)
    assert_equal nil, token.user_id
    assert_equal @client_app.id, token.client_application_id
  end
end
