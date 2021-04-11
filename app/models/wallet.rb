# frozen_string_literal: true

class Wallet < ApplicationRecord
  belongs_to :user
  enum wallet_type: { 'primary' => 'primary', 'reserve' => 'reserve', 'distro' => 'distro' }

  extend FriendlyId
  friendly_id :name, use: :slugged
end
