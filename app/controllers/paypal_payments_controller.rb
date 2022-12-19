class PaypalPaymentsController < ApplicationController

  def approved
    workflow = ExecutesPaypalPayment.new(
      payment_id: params[:paymentId],
      token: params[:token],
      payer_id: params[:PayerID]
    )
    workflow.run
    redirect_to payment_path(id: workflow.payment.reference)
  end

  def rejected
    render json:  { status: :not_implemented }
  end
end