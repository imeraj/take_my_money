class PurchaseCartViaPaypal < PurchaseCart
  attr_accessor :paypal_payment

  def update_tickets
    tickets.each(&:pending!)
  end

  def redirect_on_success_url
    paypal_payment.redirect_url
  end

  def payment_attributes
    super.merge(payment_method: "paypal")
  end

  def calculate_success
    @success = payment.pending?
  end

  def purchase
    @paypal_payment = PaypalPayment.new(payment: payment)
    payment.update(response_id: paypal_payment.response_id)
    payment.pending!
  end
end