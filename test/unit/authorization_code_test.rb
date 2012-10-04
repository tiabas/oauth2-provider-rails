require 'test_helper'

class AuthorizationCodeTest < ActiveSupport::TestCase

  def setup
    @client_app = create_dummy_client_app
    @user = create_dummy_user
  end

  def test_should_create_authorization_code
    auth_code = AuthorizationCode.generate_authorization_code(
      :client_application => @client_app,
      :user => @user,
      :redirect_uri => @client_app.redirect_uri)
    assert_equal @user.id, auth_code.user_id
    assert_equal @client_app.id, auth_code.client_application_id
    assert auth_code.code
    assert_equal @client_application.redirect_uri, auth_code.redirect_uri
  end

  def test_should_return_nil_if_code_does_not_match
    auth_code = AuthorizationCode.generate_authorization_code(
      :client_application => @client_app,
      :user => @user,
      :redirect_uri => @client_app.redirect_uri)
    kode = AuthorizationCode.verify_authorization_code(
      :client => @client_app,
      :code => 'cUAkGNuYFf0',
      :redirect_uri => @client_app.redirect_uri)
    assert_equal nil, auth_code
  end

  def test_should_return_nil_if_redirect_uri_does_not_match
    auth_code = AuthorizationCode.generate_authorization_code(
      :client_application => @client_app,
      :user => @user,
      :redirect_uri => @client_app.redirect_uri)
    kode = AuthorizationCode.verify_authorization_code(
      :client => @client_app,
      :code => auth_code.code,
      :redirect_uri => 'http://example.com')
    assert_equal nil, auth_code
  end

  def test_should_return_nil_client_does_not_match
    fake_client = create_dummy_client_app
    auth_code = AuthorizationCode.generate_authorization_code(
      :client_application => @client_app,
      :user => @user,
      :redirect_uri => @client_app.redirect_uri)
    kode = AuthorizationCode.verify_authorization_code(
      :client => fake_client,
      :code => auth_code.code,
      :redirect_uri => 'http://example.com')
    assert_equal nil, auth_code
  end

  def test_should_return_authorization_code_if_all_parameters_match
    fake_client = create_dummy_client_app
    auth_code = AuthorizationCode.generate_authorization_code(
      :client_application => @client_app,
      :user => @user,
      :redirect_uri => @client_app.redirect_uri)
    kode = AuthorizationCode.verify_authorization_code(
      :client => @client_app,
      :code => auth_code.code,
      :redirect_uri => @client_app.redirect_uri)
    assert_equal nil, auth_code
  end
end
