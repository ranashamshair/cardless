# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(first_name: "admin", email: "admin@admin.com", password: "123456", password_confirmation: "123456", role: :admin, confirmed_at: Time.now) if User.where(email: "admin@admin.com").blank?
Wallet.create(name: "Admin Primary Wallet", wallet_type: :distro, user_id: User.where(email: "admin@admin.com").first.id) if Wallet.distro.blank?
Fee.create(days: 0) if Fee.first.blank?
