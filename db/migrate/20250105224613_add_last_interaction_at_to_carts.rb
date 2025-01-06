class AddLastInteractionAtToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :last_interaction_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end