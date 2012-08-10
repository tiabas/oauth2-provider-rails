require 'test_helper'

class Oauth2ControllerTest < ActionController::TestCase
  # implicit grant

  # step 1: authorize
  # - invalid response type
  # - invalid grant type
  # - invalid redirect URI 
  # - unknown client id
  # - known client id
  # - force dialog

  test "should get authorize" do
    get :authorize
    assert_response :success
  end

  test "should get token" do
    get :token
    assert_response :success
  end

end
