module Payment
  class BlueSnap < Gateway

    attr_reader :authentication_token

    def initialize
      username = gateway_username # 'API_16230693843681027299010'
      password = gateway_password # 'Testing123!'
      @authentication_token = Base64.strict_encode64("#{username}:#{password}")
    end

    def charge(args)
      data = {
        "cardTransactionType": transaction_type,
        "amount": args[:amount], "currency": currency, # 11.00
        "cardHolderInfo": {
          "firstName": first_name(args[:card_name]), "lastName": last_name(args[:card_name])
        },
        "creditCard": {
          "cardNumber": args[:card_number], "securityCode": args[:cvv],
          "expirationMonth": expiry_month(args[:expiry_date]),
          "expirationYear": complete_exp_year(args[:expiry_date])
        }
      }
      url = 'https://sandbox.bluesnap.com/services/2/transactions'
      post_request(url, data)
    end

    def handle_charge_response(response)
      handle_response(response)
    end

    def refund
      params = {
        # 'amount' => 10
      }
      transaction_id = '1027580818'
      url = "https://sandbox.bluesnap.com/services/2/transactions/refund/#{transaction_id}"
      post_request(url, params)

      # refund response
      # "{\"refundTransactionId\":1027616102}"

      # partial_refund response
      # "{\"refundTransactionId\":1027615300,\"amount\":10}"


      # second partial refund with more then refundable amount
      #  "{\"message\":[{\"errorName\":\"REFUND_MAX_AMOUNT_FAILURE\",\"code\":\"14006\",\"description\":\"Refund amount cannot be more than the refundable order amount.\",\"invalidProperty\":{\"name\":\"amount\",\"messageValue\":\"1.00\"}}]}"
    end

    private

    def gateway_password
      payment_gateway.client_secret
    end

    def gateway_username
      payment_gateway.client_id
    end

    def post_request(url, params)
      if authentication_token.present?
        curlObj = Curl::Easy.new(url)
        curlObj.connect_timeout = 3000
        curlObj.timeout = 3000
        curlObj.headers = ["Authorization: Basic #{authentication_token}", 'Content-Type: application/json']
        curlObj.post_body = params.to_json
        curlObj.perform()
        data = curlObj.body_str
      else
        raise StandardError.new('Please Provide Api Key')
      end
    end

    def handle_response(response)
      response
    end

    def transaction_type
      'AUTH_CAPTURE'
    end
  end
end
