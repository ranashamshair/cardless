# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum role: { 'merchant' => 'merchant', 'customer' => 'customer', 'admin' => 'admin' }
  enum is_active: { 'active' => 'active', 'in_active' => 'in_active' }
  enum business_type: { 'limited_company' => 'limited_company', 'charity' => 'charity', 'individual' => 'individual',
                        'partnership' => 'partnership', 'trust' => 'trust' }
  belongs_to :payment_gateway, optional: true
  has_many :wallets
  has_many :withdraws
  has_many :banks
  has_many :sender_transactions, class_name: 'Transaction', foreign_key: :sender_id
  has_many :receiver_transactions, class_name: 'Transaction', foreign_key: :receiver_id
  validates :email, uniqueness: true
  has_many :reserve_schedules, dependent: :destroy
  after_create :create_wallets
  has_one_attached :business_license
  has_one_attached :nic
  has_one :company
  has_many :rewards

  scope :active_merchants, -> {where(is_active: :active)}

  def create_wallets
    Wallet.create(name: "#{first_name} Primary Wallet", wallet_type: :primary, user_id: id)
    Wallet.create(name: "#{first_name} Reserve Wallet", wallet_type: :reserve, user_id: id) if merchant?
  end

  def regenerate_token
    token = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.authentication_token = token
  end

  def create_oauth_app
    self.public_key = 'ID' + Digest::SHA1.hexdigest([Time.now, rand].join)
    self.secret_key = 'SE' + Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def update_without_password(params, _user)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    else
      Devise::Mailer.password_change(self).deliver_now
    end

    result = update(params)
    clean_up_passwords
    result
  end

  def country_name
    country = ISO3166::Country[self.country]
    if country.present?
      country.translations[I18n.locale.to_s] || country.name
    else
      self.country
    end

  end
end
