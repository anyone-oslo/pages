# frozen_string_literal: true

class OtpSecret
  attr_reader :user, :secret

  def initialize(user)
    @user = user
    @secret = user.otp_secret
  end

  def account_name
    user.email
  end

  def disable!
    user.update(otp_enabled: false,
                otp_secret: nil,
                last_otp_at: nil,
                recovery_codes: [])
  end

  def enable!(recovery_codes)
    user.update(otp_enabled: true,
                otp_secret: secret,
                last_otp_at: Time.zone.now,
                recovery_codes:)
  end

  def generate
    @secret = ROTP::Base32.random
  end

  def generate_recovery_codes
    10.times.map { SecureRandom.alphanumeric(16) }
  end

  def provisioning_uri
    totp.provisioning_uri(account_name)
  end

  def regenerate_recovery_codes!
    generate_recovery_codes.tap do |recovery_codes|
      user.update(recovery_codes:)
    end
  end

  def signed_message
    message_verifier.generate(
      { user_id: user.id, secret: }, expires_in: 1.hour
    )
  end

  def validate_otp!(code)
    return false unless valid_otp?(code)

    user.update(last_otp_at: Time.zone.now)
    true
  end

  def validate_otp_or_recovery_code!(code)
    if code =~ /^[\d]{6}$/
      validate_otp!(code)
    else
      validate_recovery_code!(code)
    end
  end

  def validate_recovery_code!(code)
    user.use_recovery_code!(code)
  end

  def verify(params)
    @secret = verify_secret(params[:signed_message])
    valid_otp?(params[:otp])
  end

  private

  def message_verifier
    Rails.application.message_verifier(:otp_secret)
  end

  def totp
    ROTP::TOTP.new(secret)
  end

  def valid_otp?(otp)
    if user.otp_enabled?
      totp.verify(otp, after: user.last_otp_at, drift_behind: 10)
    else
      totp.verify(otp, drift_behind: 10)
    end
  end

  def verify_secret(signed)
    payload = message_verifier.verify(signed)
    raise "Wrong user" unless payload[:user_id] == user.id

    payload[:secret]
  end
end
