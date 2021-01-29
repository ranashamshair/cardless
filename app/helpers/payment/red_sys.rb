module Payment
    class RedSys
        #4548812049400004
        def charge(card_number, exp_date, cvv, amount)
            merchant_parameters = Base64.encode64(
                {
                    "DS_MERCHANT_AMOUNT" => "#{amount}",
                    "DS_MERCHANT_CURRENCY" => "#{ENV["MERCHANTCURRENCY"]}",
                    "DS_MERCHANT_CVV2" => "#{cvv}",
                    "DS_MERCHANT_EXPIRYDATE" => "#{exp_date}",
                    "DS_MERCHANT_MERCHANTCODE" => "#{ENV["MERCHANTCODE"]}",
                    "DS_MERCHANT_PAN" => "#{card_number}",
                    "DS_MERCHANT_TERMINAL" => "#{ENV["MERCHANTTERMINAL"]}",
                    "DS_MERCHANT_TRANSACTIONTYPE" => "0"
                }.to_s)
                
            charge_detail = {
                "Ds_MerchantParameters": merchant_parameters,
                "Ds_SignatureVersion": "HMAC_SHA256_V1",
                "Ds_Signature": "#{ENV['MERCHANTSIGNATURE']}"
            }
            
            url = "#{ENV['REDSYSURL']}"
            curlObj = Curl::Easy.new(url)
            curlObj.connect_timeout = 3000
            curlObj.timeout = 3000
            curlObj.headers = ['Content-Type:application/json']
            curlObj.post_body = charge_detail.to_json
            curlObj.perform()
            data = curlObj.body_str
            binding.pry
            return JSON(data)
        end
    end
end