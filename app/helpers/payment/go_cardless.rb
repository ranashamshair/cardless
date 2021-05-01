module Payment
  class GoCardless
    require 'gocardless_pro'

    def initialize(token = nil)
      @client = GoCardlessPro::Client.new(
        access_token: token || ENV["GOCARDLESS_TOKEN"],
        environment: :sandbox
      )
    end
  end
end
