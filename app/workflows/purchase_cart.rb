class PurchaseCart
  attr_accessor :user, :stripe_token, :purchase_amount, :success, :payment

  def initialize(user:, purchase_amount_cents:)
    @user = user
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
  end

  def run
    Payment.transaction do
      update_tickets
      create_payment
      purchase
      calculate_success
    end
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def redirect_on_success_url
    nil
  end

  def calculate_success
    @success = payment.succeeded?
  end

  def create_payment
    self.payment = Payment.create!(payment_attributes)
    payment.create_line_items(tickets)
  end

  def payment_attributes
    {
      user_id: user.id, price_cents: purchase_amount.cents, price_currency: "CAD",
      status: 'created', reference: Payment.generate_reference
    }
  end

  def success?
    success
  end
end