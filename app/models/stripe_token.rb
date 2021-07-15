class StripeToken
  attr_accessor :credit_card_number, :expiration_month, :expiration_year, :cvc

  delegate :id, to: :token

  def initialize(credit_card_number:, expiration_month:, expiration_year:, cvc:)
    @credit_card_number = credit_card_number
    @expiration_month = expiration_month
    @expiration_year = expiration_year
    @cvc = cvc
  end

  def token
    @token ||= Stripe::Token.create(
      card: {
        number: credit_card_number, exp_month: expiration_month,
        exp_year: expiration_year, cvc: cvc
      })
  end

  def to_s
    "STRIPE TOKEN: #{id}"
  end

  def inspect
    "STRIPE_TOKEN #{id}"
  end
end