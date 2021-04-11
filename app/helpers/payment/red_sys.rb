# frozen_string_literal: true

require 'uri'
require 'openssl'
require 'net/http'

require 'openssl'
require 'base64'
# require 'mcrypt'
module Payment
  class RedSys

    def withdraw
      url = URI("https://apis-i.redsys.es:20443/psd2/xs2a/api-entrada-xs2a/services/caixabank/v1/payments/sepa-credit-transfers/REPLACE_PAYMENT-ID/authorisations")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER


      request = Net::HTTP::Post.new(url)
      request["x-ibm-client-id"] = 'bb0a4ee8-41b3-459c-bcd9-6cb8b8e0de0c'
      request["content-type"] = 'application/json'
      request["x-request-id"] = '1b3ab8e8-0fd5-43d2-946e-d75958b172e7'
      request["authorization"] = 'Bearer 6yBnsqnMQQ'
      request["psu-ip-address"] = '127.0.0.1'

      request["digest"] = 'REPLACE_THIS_VALUE'
      request["signature"] = 'REPLACE_THIS_VALUE'
      request["tpp-signature-certificate"] = 'REPLACE_THIS_VALUE'
      request["accept"] = 'application/json'

      response = http.request(request)
      puts response.read_body
    end


    def withdraw1

      curl --request POST \
        --url https://apis-i.redsys.es:20443/psd2/xs2a/api-entrada-xs2a/services/caixabank/v1/payments/sepa-credit-transfers/REPLACE_PAYMENT-ID/authorisations \
        --header 'accept: application/json' \
        --header 'authorization: Bearer 6yBnsqnMQQ' \
        --header 'content-type: application/json' \
        --header 'digest: REPLACE_THIS_VALUE' \
        --header 'psu-ip-address: REPLACE_THIS_VALUE' \
        --header 'psu-user-agent: REPLACE_THIS_VALUE' \
        --header 'signature: REPLACE_THIS_VALUE' \
        --header 'tpp-signature-certificate: REPLACE_THIS_VALUE' \
        --header 'x-ibm-client-id: REPLACE_THIS_KEY' \
        --header 'x-request-id: REPLACE_THIS_VALUE'
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
      merchant_key64 = Base64.decode64('sq7HjrUOBfKmC576ILgskD5srU870gJ7')
      merchant_parameters = Base64.strict_encode64({
        "DS_MERCHANT_AMOUNT": '145',
        "DS_MERCHANT_CURRENCY": '978',
        "DS_MERCHANT_CVV2": '123',
        "DS_MERCHANT_EXPIRYDATE": '1223',
        "DS_MERCHANT_MERCHANTCODE": '352263560',
        "DS_MERCHANT_ORDER": '1446068581',
        "DS_MERCHANT_PAN": '454881********04',
        "DS_MERCHANT_TERMINAL": '1',
        "DS_MERCHANT_TRANSACTIONTYPE": '0'
      }.to_json)

      bytes = [0, 0, 0, 0, 0, 0, 0, 0]
      iv = bytes.map(&:chr).join

      cipher = OpenSSL::Cipher.new('cip-her-des')
      cipher.encrypt # Call this before setting key or iv
      cipher.key = merchant_key64
      cipher.iv = iv
      ciphertext = cipher.update('1446068581')
      ciphertext << cipher.final

      digest = OpenSSL::Digest.new('sha256')
      hashh = OpenSSL::HMAC.hexdigest(digest, ciphertext, merchant_parameters)
      skey = Base64.strict_encode64(hashh)
      # crypto = Mcrypt.new(:tripledes, :cbc, merchant_key64, iv, :pkcs)
      # ciphertext = crypto.encrypt("1446068581")

      # puts "Encrypted \"#{"1446068581"}\" with \"#{Base64.decode64("sq7HjrUOBfKmC576ILgskD5srU870gJ7")}\" to:\n\"#{ciphertext}\"\n"
      # encodedCipherText = Base64.encode64(ciphertext)
      # cipher.decrypt
      # plaintext = cipher.update(Base64.decode64(encodedCipherText))
      # plaintext << cipher.final

      # Print decrypted plaintext; should match original message
      # puts "Decrypted \"#{ciphertext}\" with \"#{Base64.decode64("sq7HjrUOBfKmC576ILgskD5srU870gJ7")}\" to:\n\"#{plaintext}\"\n\n"

      charge_detail = {
        "Ds_MerchantParameters": merchant_parameters,
        "Ds_SignatureVersion": 'HMAC_SHA256_V1',
        "Ds_Signature": skey
      }

      url = 'https://sis-t.redsys.es:25443/sis/rest/trataPeticionREST'
      curlObj = Curl::Easy.new(url)
      curlObj.connect_timeout = 3000
      curlObj.timeout = 3000
      curlObj.headers = ['Content-Type:application/json']
      curlObj.post_body = charge_detail.to_json
      curlObj.perform
      data = curlObj.body_str
      JSON(data)
    end

    # def charge(card_number, exp_date, cvv, amount)
    #     merchant_parameters = Base64.encode64({
    #         "DS_MERCHANT_AMOUNT" => "#{amount}",
    #         "DS_MERCHANT_CURRENCY" => "#{ENV["MERCHANTCURRENCY"]}",
    #         "DS_MERCHANT_CVV2" => "#{cvv}",
    #         "DS_MERCHANT_EXPIRYDATE" => "#{exp_date}",
    #         "DS_MERCHANT_MERCHANTCODE" => "#{ENV["MERCHANTCODE"]}",
    #         "DS_MERCHANT_PAN" => "#{card_number}",
    #         "DS_MERCHANT_TERMINAL" => "#{ENV["MERCHANTTERMINAL"]}",
    #         "DS_MERCHANT_TRANSACTIONTYPE" => "0"
    #     }.to_json)

    #     charge_detail = {
    #         "Ds_MerchantParameters": merchant_parameters,
    #         "Ds_SignatureVersion": "HMAC_SHA256_V1",
    #         "Ds_Signature": "#{ENV['MERCHANTSIGNATURE']}"
    #     }

    #     url = "#{ENV['REDSYSURL']}"
    #     curlObj = Curl::Easy.new(url)
    #     curlObj.connect_timeout = 3000
    #     curlObj.timeout = 3000
    #     curlObj.headers = ['Content-Type:application/json']
    #     curlObj.post_body = charge_detail.to_json
    #     curlObj.perform()
    #     data = curlObj.body_str
    #     return JSON(data)
    # end
  end
end
