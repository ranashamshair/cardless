module Payment
  class SecurionPay < Gateway

    attr_accessor :authentication_token

    def initialize
      secret_key = gateway_secret_key
      @authentication_token = "#{secret_key}:"
    end

    def charge(args)
      cus_token = create_customer(args[:email])
      card_token = create_card(cus_token, args)
      amount = dollar_to_cents(args[:amount].to_i) # amount is in cents
      data = "amount=#{amount}&currency=#{currency}&card=#{card_token}&customerId=#{cus_token}"
      url = 'https://api.securionpay.com/charges'
      post_request(url, data)
    end

    def handle_charge_response(response)
      handle_response(response)
    end

    def handle_response(response)
      parsed_response = JSON.parse response
      if parsed_response && parsed_response["error"].present?
        return { message: parsed_response["error"]["message"], charge: nil,error_code: parsed_response["error"]["type"], response: response }
      else
        return { message: nil, charge: parsed_response["id"], error_code: nil, response: response }
      end
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

    def refund(args)
      params = "amount=#{dollar_to_cents(args[:amount].to_i)}"
      charge_id = args[:charge_id]
      url = "https://api.securionpay.com/charges/#{charge_id}/refund"
      post_request(url, params)
    end

    def handle_refund_response(response)
      parsed_response = JSON.parse response
      if parsed_response && parsed_response["id"].present?
        return { message: nil, refund: parsed_response["id"],refunded_amount: parsed_response["amountRefunded"], error_code: nil, response: response }
      else
        return { message: parsed_response["error"]["message"], refund: nil,error_code: parsed_response["error"]["type"], response: response }
      end
    end

    private

    def gateway_secret_key
      'sk_test_lz57hE9I5ezpuS7lj4ZulvAu'
      # payment_gateway.client_secret
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
