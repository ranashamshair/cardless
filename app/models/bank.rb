class Bank < ApplicationRecord
  belongs_to :user
  enum status: { 'in_active': 0, 'active': 1 }
end
