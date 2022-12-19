class PaymentsController < ApplicationController

  def show
    @reference = params[:id]
    @payment = Payment.find_by(reference: @reference)
  end

  def create
    workflow = create_workflow(params[:payment_type])
    workflow.run
    if workflow.success
      redirect_to workflow.redirect_on_success_url || payment_path(id: workflow.payment.reference)
    else
      redirect_to shopping_cart_path
    end
  end


  private
  def create_workflow(payment_type)
    if payment_type == "paypal"
      paypal_workflow
    else
      stripe_workflow
    end
  end

  def paypal_workflow
    PurchaseCartViaPaypal.new(
      user: current_user,
      purchase_amount_cents: params[:purchase_amount_cents]
    )
  end

  def stripe_workflow
    Rails.logger.debug("#{card_params}")
    PurchaseCartViaStripe.new(
      user: current_user,
      stripe_token: StripeToken.new(**card_params),
      purchase_amount_cents: params[:purchase_amount_cents])
  end

  def card_params
    params.permit(:credit_card_number, :expiration_month, :expiration_year, :cvc, :stripe_token).to_h.symbolize_keys
  end
end