class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {"merchant" => "merchant", "admin" => "admin"}
  enum is_active: {"active" => "active", "in_active" => "in_active"}
  belongs_to :payment_gateway, optional: true
  has_many :wallets
  has_many :withdraws

  after_create :create_wallets

  def create_wallets
    Wallet.create(name: "#{self.first_name} Primary Wallet", wallet_type: :primary, user_id: self.id)
    Wallet.create(name: "#{self.first_name} Reserve Wallet", wallet_type: :reserve, user_id: self.id)

  end
end
