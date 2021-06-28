module Payment
  class SmartPay < Gateway

    attr_reader :authentication_token

    def initialize

      api_key = gateway_api_key
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

    def handle_charge_response(response)
      handle_response(response)
    end

    def handle_response(response)
      parsed_response = JSON.parse response
      if parsed_response == ''
        return { message: 'invalid request',charge: nil,error_code: 'invalid', response: response }
      end
      return { message: nil,charge: parsed_response["id"],error_code: nil, response: response }
    end

    def refund(args)
      params = {
        "Refund": {
          # "MerchantTransactionID": "s2ptest_gi10",
          "Amount": dollar_to_cents(args[:amount]),
          # "Description": "Refund Test Description"
        }
      }
      transaction_id = args[:charge_id]
      url = "https://paytest.smart2pay.com/v1/payments/#{transaction_id}/refunds"
      post_request(url, params)
    end

    def handle_refund_response(response)
      handle_response(response)
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

    def gateway_api_key
      payment_gateway.client_secret
      # 'AFWP6d6jEycu6QNXrq839oGWtxWTJJkrMO2+se4yDzEehFDjKS'
    end
  end
end
