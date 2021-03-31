# frozen_string_literal: true

class AddPayedAtInWithdraws < ActiveRecord::Migration[6.1]
  def change
    add_column :withdraws, :payed_at, :datetime
  end
end
