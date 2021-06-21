module Payment
  class BlueSnap

    attr_reader :authentication_token

    def initialize(payment_gateway = nil)
      username = payment_gateway.client_id
      password = payment_gateway.client_secret
      # username = 'API_16230693843681027299010'
      # password = 'Testing123!'
      @authentication_token = Base64.strict_encode64("#{username}:#{password}")
    end

    def charge(amount, card, user)
      data = {
        "cardTransactionType": "AUTH_CAPTURE",
        "softDescriptor": "DescTest",
        "amount": amount,
        "currency": "EUR",
        "cardHolderInfo": {
          "firstName": user.first_name,
          "lastName": user.last_name,
          "email": user.email
        },
        "creditCard": {
          "cardNumber": card.card_number,
          "securityCode": card.cvv,
          "expirationMonth": card.exp_month,
          "expirationYear": card.exp_year
        }
      }
      url = 'https://sandbox.bluesnap.com/services/2/transactions'
      post_request(url, data)
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




  end
end
