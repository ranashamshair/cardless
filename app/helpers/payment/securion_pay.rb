module Payment
  class SecurionPay

    attr_accessor :authentication_token

    def initialize(payment_gateway = nil)
      # username = payment_gateway.client_id
      # password = payment_gateway.client_secret
      public_key = 'pk_test_diacsoPPDXgcEL3b50h3lLYU'
      secret_key = 'sk_test_lz57hE9I5ezpuS7lj4ZulvAu'
      @authentication_token = "#{secret_key}:"
    end

    def charge(amount, card)
      cus_token = create_customer
      card_token = create_card(cus_token)
      amount = '1100' # amount is in cents
      currency = 'USD'
      data = "amount=#{amount}&currency=#{currency}&card=#{card_token}&customerId=#{cus_token}"
      url = 'https://api.securionpay.com/charges'
      post_request(url, data)
    end

    def create_customer
      url = 'https://api.securionpay.com/customers'
      data = "email=shahbaz.brainarc@gmail.com"
      response = post_request(url, data)
      json_res = JSON response
      json_res['id']
    end

    def create_card(customer_token)
      url = "https://api.securionpay.com/customers/#{customer_token}/cards"
      data = "number=4242424242424242&expMonth=02&expYear=2023&cvc=1234"
      response = post_request(url, data)
      json_res = JSON response
      json_res['id']
    end

    def refund
      params = ''
      charge_id = 'char_bcYAkTClxuh0wSE1YGQ7YjWq'
      url = "https://api.securionpay.com/charges/#{charge_id}/refund"
      post_request(url, params)
    end

    private

    def post_request(url, params = '')
      if authentication_token.present?
        curlObj = Curl::Easy.new(url)
        curlObj.http_auth_types = :basic
        curlObj.username = authentication_token
        curlObj.connect_timeout = 3000
        curlObj.timeout = 3000
        # curlObj.headers = ["Authorization: Basic #{authentication_token}", 'Content-Type: application/json']
        curlObj.post_body = params
        curlObj.perform()
        data = curlObj.body_str
      else
        raise StandardError.new('Please Provide Api Key')
      end
    end
  end
end
