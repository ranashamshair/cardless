# frozen_string_literal: true

class Bank < ApplicationRecord
  belongs_to :user
  has_many :withdraws
  enum status: { 'in_active': 0, 'active': 1 }
end
