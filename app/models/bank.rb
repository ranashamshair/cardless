# frozen_string_literal: true

class Bank < ApplicationRecord
  belongs_to :user
  has_many :withdraws
  has_many :transactions
  enum status: { 'in_active': 0, 'active': 1 }
end
