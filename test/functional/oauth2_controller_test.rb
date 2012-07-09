require 'test_helper'

class Oauth2ControllerTest < ActionController::TestCase
  test "should get authorize" do
    get :authorize
    assert_response :success
  end

  test "should get token" do
    get :token
    assert_response :success
  end

end
