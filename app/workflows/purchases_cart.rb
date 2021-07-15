class PurchasesCart
  attr_accessor :user, :stripe_token, :purchase_amount, :success, :payment

  def initialize(user:, stripe_token:, purchase_amount_cents:)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
  end

  def tickets
    @tickets ||= user.tickets_in_cart
  end

  def run
    Payment.transaction do
      purchase_tickets
      create_payment
      charge
      @success = payment.succeeded?
    end
  end

  private

  def purchase_tickets
    tickets.each(&:purchased!)
  end

  def create_payment
    self.payment = Payment.create!(payment_attributes)
    payment.create_line_items(tickets)
  end

  def payment_attributes
    {
      user_id: user.id, price_cents: purchase_amount.cents,
      status: 'created', reference: Payment.generate_reference,
      payment_method: 'stripe'
    }
  end

  def charge
    charge = StripeCharge.new(token: stripe_token, payment: payment)
    charge.charge
    response = charge.results

    payment.update!(
      status: response[:status], response_id: response[:id], full_response: response[:full_response]
    )

    raise ActiveRecord::Rollback if response[:status] != :succeeded
  end
end