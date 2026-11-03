# frozen_string_literal: true

module PagesCore
  # = Digest Verifier
  #
  # ==== Usage
  #
  #   verifier = PagesCore::DigestVerifier.new("super secret!")
  #
  #   digest = verifier.generate("foo")
  #
  #   digest.verify("foo", digest)
  #   # => "foo"
  #   digest.verify("bar", digest)
  #   # => raises PagesCore::Errors::InvalidSignature
  #
  # Credit where credit is due: adapted and simplified from
  # +ActiveSupport::MessageVerifier+, since we don't need to handle
  # arbitrary data structures and ship the serialized data to the client.
  class DigestVerifier
    class InvalidSignatureError < StandardError; end

    def initialize(secret, options = {})
      @secret = secret
      @digest = options[:digest] || "SHA1"
    end

    # Generates a digest for a string.
    def generate(data)
      generate_digest(data)
    end

    # Verifies that <tt>digest</tt> is valid for <tt>data</tt> and returns
    # the data. Raises a +PagesCore::DigestVerifier::InvalidSignatureError+
    # error if not.
    def verify(data, digest)
      raise PagesCore::DigestVerifier::InvalidSignatureError unless valid_digest?(data, digest)

      data
    end

    private

    def generate_digest(data)
      require "openssl" unless defined?(OpenSSL)
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.const_get(@digest).new,
        @secret,
        data
      )
    end

    def valid_digest?(data, digest)
      data.present? &&
        digest.is_a?(String) &&
        digest.present? &&
        ActiveSupport::SecurityUtils.secure_compare(digest, generate_digest(data))
    end
  end
end
