module Payment
  class SecurionPay < Gateway

    attr_accessor :authentication_token

    def initialize
      secret_key = gateway_secret_key #'sk_test_lz57hE9I5ezpuS7lj4ZulvAu'
      @authentication_token = "#{secret_key}:"
    end

    def charge(args)
      cus_token = create_customer(args[:email])
      card_token = create_card(cus_token, args)
      amount = dollar_to_cents(args[:amount]) # amount is in cents
      data = "amount=#{amount}&currency=#{currency}&card=#{card_token}&customerId=#{cus_token}"
      url = 'https://api.securionpay.com/charges'
      post_request(url, data)
    end

    def create_customer(email)
      url = 'https://api.securionpay.com/customers'
      data = "email=#{email}"
      response = post_request(url, data)
      json_res = JSON response
      json_res['id']
    end

    def create_card(customer_token, args)
      url = "https://api.securionpay.com/customers/#{customer_token}/cards"
      data = "number=#{args[:card_number]}&expMonth=#{expiry_month(args[:expiry_date])}&expYear=#{complete_exp_year(args[:expiry_date])}&cvc=#{args[:cvv]}"
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

    def gateway_secret_key
      payment_gateway.client_secret
    end

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
