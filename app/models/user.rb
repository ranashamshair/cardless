class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,:confirmable

  enum role: {"merchant" => "merchant", "customer" => "customer", "admin" => "admin"}
  enum is_active: {"active" => "active", "in_active" => "in_active"}
  enum business_type: {"limited_company" => "limited_company", "charity" => "charity", "individual" => "individual","partnership" => "partnership", "trust" => "trust"}
  belongs_to :payment_gateway, optional: true
  has_many :wallets
  has_many :withdraws
  has_many :banks
  has_many :sender_transactions, class_name: "Transaction", foreign_key: :sender_id
  has_many :receiver_transactions, class_name: "Transaction", foreign_key: :receiver_id
  validates :email, uniqueness: true
  has_many :reserve_schedules, dependent: :destroy
  after_create :create_wallets

  def create_wallets
    Wallet.create(name: "#{self.first_name} Primary Wallet", wallet_type: :primary, user_id: self.id)
    Wallet.create(name: "#{self.first_name} Reserve Wallet", wallet_type: :reserve, user_id: self.id) if self.merchant?
  end

  def regenerate_token
    token = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.authentication_token = token
  end

  def create_oauth_app
    self.public_key = 'ID' + Digest::SHA1.hexdigest([Time.now, rand].join)
    self.secret_key = 'SE' + Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
