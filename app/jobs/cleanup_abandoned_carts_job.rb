class CleanupAbandonedCartsJob < ApplicationJob
  queue_as :default

  def perform
    Cart.where(status: :open)
        .where(last_interaction_at: ..3.hours.ago)
        .find_each(&:mark_as_abandoned)

    Cart.where(status: :abandoned)
        .where(last_interaction_at: ..7.days.ago)
        .find_each(&:remove_if_abandoned)
  end
end
