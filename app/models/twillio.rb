require 'twilio-ruby'

class Twillio
  attr_accessor :user

  SERVICE_SID = Rails.application.credentials.twillio[:service_sid]
  ACCOUNT_SID = Rails.application.credentials.twillio[:account_sid]
  AUTH_TOKEN  = Rails.application.credentials.twillio[:auth_token]

  APPROVED    = "approved".freeze

  def initialize(user)
    @user = user
  end

  def client
    @client ||= Twilio::REST::Client.new(ACCOUNT_SID, AUTH_TOKEN)
    myLogger = Logger.new(STDOUT)
    myLogger.level = Logger::DEBUG
    @client.logger = myLogger
    @client
  end

  def request_sms
    client.verify
          .services(SERVICE_SID)
          .verifications
          .create(to: '+14155697297', channel: 'sms')
  end

  def request_email
    client.verify
      .services(SERVICE_SID)
      .verifications
      .create(to: user.email, channel: 'email')
  end

  def verify(code)
    # disable for now
    return true
    return false if code.blank?
    return false unless valid_format?(code)

    verification_check =
      client.verify
            .services(SERVICE_SID)
            .verification_checks
            .create(to: user.email, code: code)

    verification_check.status == APPROVED
  end

  private
  def valid_format?(code)
    code.scan(/\D/).empty?
  end

end