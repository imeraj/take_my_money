class StripeCharge
  attr_accessor :token, :payment, :response, :error

  def initialize(token:, payment:)
    @token = token
    @payment = payment
  end

  def charge
    return if response.present?

    @response = Stripe::Charge.create(
      {
        amount: payment.price.cents, currency: "cad",
        source: token.id, description: "",
        metadata: {reference: payment.reference}},
        idempotency_key: payment.reference
    )
  rescue Stripe::StripeError => e
    @response = nil
    @error = e
  end

  def success?
    response || !error
  end

  def results
    payment_attributes
  end

  def payment_attributes
    success? ? success_attributes : failure_attributes
  end

  def success_attributes
    {
      status: :succeeded,
      response_id: response.id,
      full_response: response.to_json
    }
  end

  def failure_attributes
    {
      status: :failed,
      response_id: nil,
      full_response: error.to_json
    }
  end

end