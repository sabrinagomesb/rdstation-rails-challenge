require 'rails_helper'

RSpec.describe CleanupAbandonedCartsJob, type: :job do
  describe "#perform" do
    context "when there are open carts inactive for more than 3 hours" do
      let!(:active_cart) { create(:cart, status: 'open', last_interaction_at: 2.hours.ago) }
      let!(:abandoned_cart) { create(:cart, status: 'open', last_interaction_at: 4.hours.ago) }

      it "marks only the carts inactive for more than 3 hours as abandoned" do
        CleanupAbandonedCartsJob.perform_now
        expect(abandoned_cart.reload.abandoned?).to be_truthy
        expect(active_cart.reload.abandoned?).to be_falsey
      end
    end

    context "when there are abandoned carts inactive for more than 7 days" do
      let!(:recent_abandoned_cart) { create(:cart, status: 'abandoned', last_interaction_at: 6.days.ago) }
      let!(:old_abandoned_cart) { create(:cart, status: 'abandoned', last_interaction_at: 8.days.ago) }

      it "removes only the carts abandoned for more than 7 days" do
        expect {
          CleanupAbandonedCartsJob.perform_now
        }.to change { Cart.count }.by(-1)

        expect(Cart.exists?(old_abandoned_cart.id)).to be_falsey
        expect(Cart.exists?(recent_abandoned_cart.id)).to be_truthy
      end
    end

    context "when there are no carts to update or remove" do
      let!(:active_cart) { create(:cart, status: 'open', last_interaction_at: 1.hour.ago) }
      let!(:abandoned_recent_cart) { create(:cart, status: 'abandoned', last_interaction_at: 5.days.ago) }

      it "does not change any carts" do
        expect {
          CleanupAbandonedCartsJob.perform_now
        }.not_to change { Cart.count }

        expect(active_cart.reload.abandoned?).to be_falsey
        expect(abandoned_recent_cart.reload.abandoned?).to be_truthy
      end
    end

    context "when carts have edge case timestamps" do
      let!(:exactly_3_hours_ago_cart) { create(:cart, status: 'open', last_interaction_at: 3.hours.ago) }
      let!(:exactly_7_days_ago_cart) { create(:cart, status: 'abandoned', last_interaction_at: 7.days.ago) }

      it "marks the cart as abandoned if exactly 3 hours inactive" do
        CleanupAbandonedCartsJob.perform_now
        expect(exactly_3_hours_ago_cart.reload.abandoned?).to be_truthy
      end

      it "removes the cart if exactly 7 days abandoned" do
        expect {
          CleanupAbandonedCartsJob.perform_now
        }.to change { Cart.count }.by(-1)
        expect(Cart.exists?(exactly_7_days_ago_cart.id)).to be_falsey
      end
    end

    context "when multiple carts qualify for abandonment and removal" do
      let!(:abandoned_carts) { create_list(:cart, 3, status: 'open', last_interaction_at: 5.hours.ago) }
      let!(:removable_abandoned_carts) { create_list(:cart, 2, status: 'abandoned', last_interaction_at: 10.days.ago) }

      it "marks all qualifying open carts as abandoned and removes all qualifying abandoned carts" do
        expect {
          CleanupAbandonedCartsJob.perform_now
        }.to change { Cart.count }.by(-2)

        abandoned_carts.each do |cart|
          expect(cart.reload.abandoned?).to be_truthy
        end

        removable_abandoned_carts.each do |cart|
          expect(Cart.exists?(cart.id)).to be_falsey
        end
      end
    end
  end
end
