class OauthClientApplication < ActiveRecord::Base
	attr_accessible :name, :website, :description, :client_type

	CLIENT_TYPES = %w{ native web user-agent }

	validates :name, :website, :redirect_uri, :description, :client_type, :presence => true
	validates :client_id, :uniqueness =>  { :case_sensitive => false }
	validates :client_secret, :uniqueness => true
	validates :client_type, :inclusion => { :in => CLIENT_TYPES }
	validates :terms_of_service, :acceptance => true, :on => :create_client_id

	before_save :create_client_id,     :on => :create
	before_save :create_client_secret, :on => :create 

  private

		def verify_code
			self.code_created_at < 10.minutes.ago
		end

		def generate_code
			self.code = generate_base_64_string
			self.code_created_at = Time.now
			self.save
		end

		def create_client_id
			generate_base_64_string
		end

		def create_client_secret
			require 'digest/sha2'
			Digest::SHA2.new.to_s
		end

		def generate_base_64_string
			require 'base64'
			Base64.urlsafe_encode64 "#{Time.now.utc}"
		end

end
