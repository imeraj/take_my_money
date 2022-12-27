class PurchaseCart
  attr_accessor :user, :stripe_token, :purchase_amount, :success, :payment, :expected_ticket_ids

  def initialize(user: nil, purchase_amount_cents: nil, expected_ticket_ids: "")
    @user = user
    @purchase_amount = Money.new(purchase_amount_cents)
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
    @continue = true
    @success = false
  end

  def run
    Payment.transaction do
      pre_purchase
      purchase
      post_purchase
      @success = @continue
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error("ACTIVE RECORD ERROR IN TRANSACTION")
      Rails.logger.error(e)
    end
  end

  def pre_purchase_valid?
    purchase_amount == tickets.map(&:price).sum &&
      expected_ticket_ids == tickets.map(&:id).sort
  end

  def pre_purchase
    unless pre_purchase_valid?
      @continue = false
      return
    end
    update_tickets
    create_payment
    @continue = true
  end

  def post_purchase
    return unless @continue
    @continue = calculate_success
  end

  def calculate_success
    payment.succeeded?
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