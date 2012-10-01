require File.expand_path("../../test_helper", __FILE__)

class ClientApplicationsControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create a new client application" do
    params = {
      :name => "My first application",
      :description => "This is a really awesome application",
      :website => "http://example.com",
      :client_type => '1',
      :redirect_uri => 'http://example.com/oauth/v2/callback',
      :terms_of_service => '1'
    }
    assert_difference('ClientApplication.count', 1) do
      post :create, :client_application => params
    end
    app = ClientApplication.last
    assert_redirected_to :action => :show, :id => app.id 
  end

  #terms of service not included
  test "should show terms of service blank error" do
    params = {
      :name => "My first application",
      :description => "This is a really awesome application",
      :website => "http://example.com",
      :client_type => '1',
      :redirect_uri => 'http://example.com/oauth/v2/callback',
    }
    post :create, :client_application => params
    assert flash[:error][:terms_of_service].include?("can't be blank")
  end

  #terms of service not checked
  test "should show terms of service required error" do
    params = {
      :name => "My first application",
      :description => "This is a really awesome application",
      :website => "http://example.com",
      :client_type => '1',
      :redirect_uri => 'http://example.com/oauth/v2/callback',
      :terms_of_service => '0'
    }
    post :create, :client_application => params
    puts flash[:error].inspect
    assert flash[:error][:terms_of_service].include?("must be accepted")
  end

  #invalid website url
  test "should show website url required error" do
    params = {
      :name => "My first application",
      :description => "This is a really awesome application",
      :client_type => '1',
      :redirect_uri => 'http://example.com/oauth/v2/callback',
      :terms_of_service => '1'
    }
    post :create, :client_application => params
    assert flash[:error][:website] 
  end

  #invalid redirect url
  test "should show redirect uri required error" do
    params = {
      :name => "My first application",
      :description => "This is a really awesome application",
      :website => "http://example.com",
      :client_type => '1',
      :terms_of_service => '1'
    }
    post :create, :client_application => params
    assert flash[:error][:redirect_uri] 
  end

  #invalid client type
  test "should show invalid client type error" do
    params = {
      :name => "My first application",
      :description => "This is a really awesome application",
      :website => "http://example.com",
      :client_type => '5',
      :redirect_uri => 'http://example.com/oauth/v2/callback',
      :terms_of_service => '1'
    }
    post :create, :client_application => params
    assert flash[:error][:client_type] 
  end
end
