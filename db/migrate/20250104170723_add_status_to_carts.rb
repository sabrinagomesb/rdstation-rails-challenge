# frozen_string_literal: true

class AddStatusToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :string, null: false, default: 'open'
  end
end
