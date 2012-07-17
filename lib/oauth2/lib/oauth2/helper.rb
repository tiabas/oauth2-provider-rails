require 'openssl'
require 'base64'

module OAuth2
  module Helper
    extend self

    # Generate a random key of up to +size+ bytes. The value returned is Base64 encoded with non-word
    # characters removed.
    def generate_key(size=32)
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
    end
    alias_method :generate_nonce, :generate_key

    def generate_timestamp #:nodoc:
      Time.now.to_i.to_s
    end

  end
end