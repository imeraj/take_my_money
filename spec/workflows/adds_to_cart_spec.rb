require 'rails_helper'

RSpec.describe AddsToCart do
  let(:user) { create(:user) }
  let(:event) { create(:event)}
  let(:performance) { create(:performance, event: event) }
  let(:ticket_1) { create(:ticket, performance: performance, status: "unsold") }
  let(:ticket_2) { create(:ticket, performance: performance, status: "unsold") }

  context "when there are enough tickets to fulfill the order" do
    it "adds tickets to the shopping cart" do
      expect(performance).to receive(:unsold_tickets).with(1).and_return([ticket_1])

      workflow = AddsToCart.new(user: user, performance: performance, count: 1)
      workflow.run

      expect(workflow.success).to be(true)
      expect(ticket_1.status).to eq("waiting")
    end
  end

  context "when there are not enough tickets to fulfill the order" do
    it "does not add tickets to the shopping cart" do
      allow(performance).to receive(:unsold_tickets).with(1).and_return([])

      workflow = AddsToCart.new(user: user, performance: performance, count: 1)
      workflow.run

      expect(workflow.success).to be(false)
      expect(ticket_1.status).to eq("unsold")
      expect(ticket_2.status).to eq("unsold")
    end
  end
end