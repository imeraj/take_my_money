class PaymentsController < ApplicationController

  def show
    @reference = params[:id]
    @payment = Payment.find_by(reference: @reference)
  end

  def create
    token = StripeToken.new(**card_params)
    workflow = PurchasesCart.new(
      user: current_user, stripe_token: token, purchase_amount_cents: params[:purchase_amount_cents]
    )
    workflow.run

    if workflow.success
      redirect_to payment_path(id: workflow.payment.reference)
    else
      redirect_to shopping_cart_path
    end
  end

  private def card_params
    params.permit(:stripe_token).to_h.symbolize_keys
  end
end