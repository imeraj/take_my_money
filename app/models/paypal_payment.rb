class PaypalPayment
  attr_accessor :payment, :paypal_payment

  delegate :create, to: :paypal_payment
  delegate :execute, to: :paypal_payment

  def self.find(payment_id)
    PayPal::SDK::REST::Payment.find(payment_id)
  end

  def initialize(payment:)
    @payment = payment
    @paypal_payment = build_paypal_payment
  end

  def build_paypal_payment
    PayPal::SDK::REST::Payment.new(intent: "sale", payer: {payment_method: "paypal"},
                                   redirect_urls: redirect_info, transactions: [payment_info])
  end

  def host_name
    Rails.application.secrets.host_name || "localhost:3000"
  end

  def redirect_info
    {
      return_url: "http://#{host_name}/paypal/approved",
      cancel_url: "http://#{host_name}/paypal/rejected"
    }
  end

  def payment_info
    {
      # item_list: {items: build_item_list},
      amount: {total: payment.price.format(symbol: false), currency: "CAD"}
    }
  end

  def build_item_list
    payment.payment_line_items.map do |payment_line_item|
      {
        name: "Ticket",
        sku: payment_line_item.id,
        price: payment_line_item.price.format(symbol: false),
        currency: payment_line_item.price_currency,
        quantity: payment.payment_line_items.size
      }
    end
  end

  def created?
    paypal_payment.state == "created"
  end

  def redirect_url
    create unless created?
    paypal_payment.links.find { |link| link.method == "REDIRECT" }.href
  end

  def response_id
    create unless created?
    paypal_payment.id
  end
end