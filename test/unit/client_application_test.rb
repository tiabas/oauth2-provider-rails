require File.expand_path("../../test_helper", __FILE__)

class ClientApplicationTest < ActiveSupport::TestCase

  def setup
    @attributes = {
      :name => 'Test Client Application',
      :website => 'https://example.com',
      :redirect_uri => 'https://example.com/oauth/v2/callback',
      :description => 'Not the coolest app on the market',
      :terms_of_service => '1'
    }
  end

  def test_creation_of_client_application_with_attributes_satisfied
    attrs = @attributes
    app = ClientApplication.new(attrs)
    app.client_type = '1'
    assert_difference('ClientApplication.count', 1) do
      app.save!
    end
    assert app.client_id
    assert app.client_secret
  end

  def test_reset_client_secret_of_client_application
    attrs = @attributes
    app = ClientApplication.new(attrs)
    app.client_type = '1'
    app.save!
    client_secret = app.client_secret
    app.reset_client_secret!
    assert_not_equal client_secret, app.client_secret
  end

  def test_authenticate_client_secret_of_client_application
    attrs = @attributes
    app = ClientApplication.new(attrs)
    app.client_type = '1'
    app.save!
    client_secret = app.client_secret
    assert app.authenticate(client_secret)
  end

  def test_creation_of_client_application_without_accepting_terms
    attrs = @attributes.merge(:terms_of_service => false)
    app = ClientApplication.new(attrs)
    app.client_type = '1'
    assert_equal false, app.valid?
    assert_equal false, app.errors[:terms_of_service].empty?
  end

  def test_creation_of_client_application_with_client_id_specified
    attrs = @attributes.merge(:client_id => 'cUAkGNuYFFo')
    assert_raises ActiveModel::MassAssignmentSecurity::Error do
      app = ClientApplication.new(attrs)
    end
  end

  def test_creation_of_client_application_with_client_secret_specified
    attrs = @attributes.merge(:client_secret => 'HUAkeHuYRFtCo')
    assert_raises ActiveModel::MassAssignmentSecurity::Error do
      app = ClientApplication.new(attrs)
    end
  end
end
