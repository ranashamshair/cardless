# frozen_string_literal: true

require 'openssl'
require 'base64'
# require 'mcrypt'
module Payment
  class RedSys
    # 4548812049400004
    def charge
      merchant_key64 = Base64.decode64('sq7HjrUOBfKmC576ILgskD5srU870gJ7')
      merchant_parameters = Base64.strict_encode64({
        "DS_MERCHANT_AMOUNT": '145',
        "DS_MERCHANT_CURRENCY": '978',
        "DS_MERCHANT_CVV2": '123',
        "DS_MERCHANT_EXPIRYDATE": '1512',
        "DS_MERCHANT_MERCHANTCODE": '352263560',
        "DS_MERCHANT_ORDER": '1446068581',
        "DS_MERCHANT_PAN": '4548812049400004',
        "DS_MERCHANT_TERMINAL": '1',
        "DS_MERCHANT_TRANSACTIONTYPE": '0'
      }.to_json)

      bytes = [0, 0, 0, 0, 0, 0, 0, 0]
      iv = bytes.map(&:chr).join

      cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
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
