# frozen_string_literal: true

require 'uri'
require 'openssl'
require 'net/http'

require 'base64'
# require 'mcrypt'
module Payment
  class RedSys

    def withdraw
      url = URI("https://apis-i.redsys.es:20443/psd2/xs2a/api-entrada-xs2a/services/caixabank/v1/payments/sepa-credit-transfers/#{rand.to_s[2..6]}/authorisations")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER


      request = Net::HTTP::Post.new(url)
      request["x-ibm-client-id"] = 'bb0a4ee8-41b3-459c-bcd9-6cb8b8e0de0c'
      request["content-type"] = 'application/json'
      request["x-request-id"] = SecureRandom.hex
      request["authorization"] = 'Bearer 6yBnsqnMQQ'
      request["psu-ip-address"] = '127.0.0.1'

      request["digest"] = 'REPLACE_THIS_VALUE'
      request["signature"] = 'REPLACE_THIS_VALUE'
      request["tpp-signature-certificate"] = 'REPLACE_THIS_VALUE'
      request["accept"] = 'application/json'

      response = http.request(request)
      puts response.read_body
    end

    def genrate_digest
      digest = ""
      body_text = "application/json"
      sha256 = Digest::SHA256.new
      digest = sha256.base64digest body_text
      digest = "SHA-256=" + digest
    end

    # 4548812049400004
    def charge
      data = signed_request_order(merchant_parameters_hash)
      url = 'https://sis-t.redsys.es:25443/sis/rest/trataPeticionREST'
      curlObj = Curl::Easy.new(url)
      curlObj.connect_timeout = 3000
      curlObj.timeout = 3000
      curlObj.headers = ['Content-Type:application/json']
      curlObj.post_body = data.to_json
      curlObj.perform
      data = curlObj.body_str
      JSON(data)
    end

    def insite_authorize(id, order_id,tx_type)
      data = signed_request_order(insite_params(id, order_id,tx_type))
      url = 'https://sis-t.redsys.es:25443/sis/rest/trataPeticionREST'
      curlObj = Curl::Easy.new(url)
      curlObj.connect_timeout = 3000
      curlObj.timeout = 3000
      curlObj.headers = ['Content-Type:application/json']
      curlObj.post_body = data.to_json
      curlObj.perform
      data = curlObj.body_str
      JSON(data)
    end



    def merchant_parameters_hash
      {
        "Ds_Merchant_Amount" => 4999,
        "Ds_Merchant_Currency" => 978,
        "Ds_Merchant_ProductDescription" => "Jacket",
        "Ds_Merchant_MerchantCode" => 352263560,
        "Ds_Merchant_MerchantURL" => "https://distropayment.com/callback/",
        # "Ds_Merchant_UrlOK" => "https://www.example.com/payment/ok/",
        # "Ds_Merchant_UrlKO" => "https://www.example.com/payment/ko/",
        "Ds_Merchant_MerchantName" => "ACME",
        "Ds_Merchant_Terminal" => 2,
        "Ds_Merchant_TransactionType" => 0,
        "Ds_Merchant_Order" =>  rand.to_s[2..6],
        # "DS_MERCHANT_PAN" => '454881********04',
        # "DS_MERCHANT_CVV2" => '123',
        # "DS_MERCHANT_EXPIRYDATE" => '1223',
      }
    end

    def insite_params(id, order_id, tx_type)
      {
        "DS_MERCHANT_IDOPER" => id,
        "Ds_Merchant_Order" => order_id,
        "Ds_Merchant_MerchantCode" => 352263560,
        "Ds_Merchant_Terminal" => 2,
        "Ds_Merchant_TransactionType" => tx_type,
        "Ds_Merchant_Currency" => 978,
        "Ds_Merchant_Amount" => 4999,
      }
    end


    def signed_request_order(merchant_parameters)
      encoded_parameters = encode_parameters(merchant_parameters)
      signature = calculate_signature(encoded_parameters, merchant_parameters["Ds_Merchant_Order"])
      {
        "Ds_SignatureVersion" => "HMAC_SHA256_V1",
        "Ds_MerchantParameters" => encoded_parameters,
        "Ds_Signature" => signature
      }
    end

    def encode_parameters(parameters)
      Base64.strict_encode64(parameters.to_json)
    end

    def calculate_signature(b64_parameters, ds_order)
      unique_key_per_order = encrypt_3DES(ds_order, Base64.decode64("sq7HjrUOBfKmC576ILgskD5srU870gJ7"))
      sign_hmac256(b64_parameters, unique_key_per_order)
    end

    def encrypt_3DES(data, key)
      cipher = OpenSSL::Cipher::Cipher.new("DES-EDE3-CBC")
      cipher.encrypt
      cipher.key = key
      if (data.bytesize % 8) > 0
        data += "\0" * (8 - data.bytesize % 8)
      end
      cipher.update(data)
    end

    def sign_hmac256(data, key)
      Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data))
    end


    #verify response key
    def redsys_response_parameters(data)
      decode_parameters(data)
    end

    def decode_parameters(parameters)
       JSON.parse(Base64.decode64(parameters.tr("-_", "+/")))
    end

    def check_response_signature(order_id, signature, merchant_data)
      response_signature = Base64.strict_encode64(Base64.urlsafe_decode64(signature))
      raise InvalidSignatureError unless response_signature == calculate_signature(merchant_data, order_id)
    end
  end
end
