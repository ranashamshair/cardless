class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {"merchant" => "merchant", "admin" => "admin"}
  enum is_active: {"active" => "active", "in_active" => "in_active"}
  belongs_to :payment_gateway, optional: true
end
