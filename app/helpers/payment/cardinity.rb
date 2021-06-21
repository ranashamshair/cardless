module Payment
  class Cardinity < Gateway

    attr_reader :authentication_token

    def initialize
      your_consumer_key = ''
      computed_oauth_signature = ''
      @authentication_token = "oauth_consumer_key='#{your_consumer_key}',
      oauth_signature_method='HMAC-SHA1',
      oauth_timestamp='#{Time.now}',
      oauth_nonce='#{rand(999)}#{Time.now.to_i}',
      oauth_version='1.0',
      oauth_signature='#{computed_oauth_signature}'"
    end

    def charge()
      data = {
        "amount": "50.00",
        "currency": currency,
        "settle": false,
        "description": "some description",
        "order_id": "12345678",
        "country": "LT",
        "payment_method": "card",
        "payment_instrument": {
          "pan": "4111111111111111",
          "exp_year": 2021,
          "exp_month": 11,
          "cvc": "999",
          "holder": "Mike Dough"
        }
      }
      url = 'https://api.cardinity.com/v1/payments'
      post_request(url, data)
    end

    def refund
      params = {
        "amount": "10.00",
        "description": "some description"
      }
      transaction_id = ''
      url = "https://api.cardinity.com/v1/payments/#{transaction_id}/refunds"
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
