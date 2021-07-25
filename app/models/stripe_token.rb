class StripeToken
  attr_accessor :stripe_token

  delegate :id, to: :token

  def initialize(stripe_token:)
    @stripe_token = stripe_token
  end

  def token
    @token ||= stripe_token
  end

  def id
    stripe_token
  end

  def to_s
    "STRIPE TOKEN: #{id}"
  end

  def inspect
    "STRIPE_TOKEN #{id}"
  end
end