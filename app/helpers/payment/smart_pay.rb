module Payment
  class SmartPay < Gateway

    attr_reader :authentication_token

    def initialize(payment_gateway = nil)

      api_key = 'AFWP6d6jEycu6QNXrq839oGWtxWTJJkrMO2+se4yDzEehFDjKS'
      @authentication_token = api_key
    end

    def charge(args)
      data = {
        "Payment": {
          # "MerchantTransactionID": 's2p_test_h2',
          "Amount": dollar_to_cents(args[:amount]),
          "Currency": currency,
          "Card": {
            "HolderName": args[:card_name],
            "Number": args[:card_number],
            "ExpirationMonth": expiry_month(args[:expiry_date]),
            "ExpirationYear": complete_exp_year(args[:expiry_date]),
            "SecurityCode": args[:cvv]
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
