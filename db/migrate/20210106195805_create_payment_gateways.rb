# frozen_string_literal: true

class CreatePaymentGateways < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_gateways do |t|
      t.integer :type
      t.string :name
      t.text :client_secret
      t.text :client_id
      t.boolean :is_block, default: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
