require "rails_helper"

describe ExecutesPaypalPayment, :vcr, :aggregate_failures do
  describe "successful credit card purchase" do
    let!(:ticket_1) { instance_spy(Ticket, status: "pending", price: Money.new(1500)) }
    let!(:ticket_2) { instance_spy(Ticket, status: "pending", price: Money.new(1500)) }
    let!(:ticket_3) { instance_spy(Ticket, status: "unsold", price: Money.new(1500)) }
    let(:payment) { instance_spy(Payment, tickets: [ticket_1, ticket_2])}
    let(:paypal_payment) { instance_spy(PaypalPayment, execute: true) }
    let(:user) { instance_spy(User, tickets_in_cart: [ticket_1, ticket_2]) }
    let(:workflow) { ExecutesPaypalPayment.new(payment_id: "PAYMENTID", token: "TOKEN", payer_id: "PAYER_ID")}

    before(:example) do
      allow(workflow).to receive(:payment).and_return(payment)
      allow(workflow).to receive(:paypal_payment).and_return(paypal_payment)
      workflow.run
    end

    it "updates ticket status" do
      expect(ticket_1).to have_received(:purchased!)
      expect(ticket_2).to have_received(:purchased!)
      expect(ticket_3).not_to have_received(:purchased!)
      expect(payment).to have_received(:succeeded!)
      expect(paypal_payment).to have_received(:execute)
      expect(workflow.success).to be_truthy
    end
  end
end