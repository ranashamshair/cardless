# frozen_string_literal: true

json.extract! withdraw, :id, :name, :user_id, :is_payed, :amount, :created_at, :updated_at
json.url withdraw_url(withdraw, format: :json)
