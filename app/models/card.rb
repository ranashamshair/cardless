# frozen_string_literal: true

class Card < ApplicationRecord
  belongs_to :user

  def self.neutrino_post(number)
    url = ENV['NEUTRINO_API']
    parameters = {
      'user-id' => ENV['CARD_BIN_USER'],
      'api-key' => ENV['CARD_BIN_LIST_KEY'],
      'bin-number' => number
    }
    response = RestClient.post(url, parameters, { content_type: :json, accept: :json })
    response = JSON.parse(response)
  end
end
