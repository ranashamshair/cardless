# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'twilio-ruby'
require 'iban-tools'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cardless
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.filter_parameters += [:card_number,:cvc]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
