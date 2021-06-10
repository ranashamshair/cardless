module Payment
  class SmartPay

    attr_reader :authentication_token

    def initialize(payment_gateway = nil)
      api_key = 'AFWP6d6jEycu6QNXrq839oGWtxWTJJkrMO2+se4yDzEehFDjKS'
      @authentication_token = api_key
    end

    def charge(amount, card)
      data = {
        "Payment": {
          "MerchantTransactionID": "s2ptest_h2",
          "Amount": 2000,
          "Currency": "EUR",
          "Card": {
            "HolderName": "John Doe",
            "Number": "4111111111111111",
            "ExpirationMonth": "01",
            "ExpirationYear": "2022",
            "SecurityCode": "312"
          },
          "Capture": true
        }
      }
      url = 'https://securetest.smart2pay.com/v1/payments'
      post_request(url, data)
    end

    def refund
      params = {
        "Refund": {
          "MerchantTransactionID": "s2ptest_gi10",
          "Amount": 100,
          "Description": "Refund Test Description"
        }
      }
      transaction_id = ''
      url = "https://paytest.smart2pay.com/v1/payments/#{transaction_id}/refunds"
      post_request(url, params)
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
