include AuthorizeNet::API
module Payment
  class AuthorizePay < Gateway

    attr_reader :gateway_transaction, :gateway_request

    def initialize
      api_login_id = gateway_api_login_id # '3DTub79c'
      api_transaction_key = gateway_api_transaction_key # '5w2tXY47wR97VnNk'
      environment = sandbox

      @gateway_transaction = AuthorizeNet::API::Transaction.new(api_login_id, api_transaction_key, gateway: environment)
      @gateway_request = CreateTransactionRequest.new
      gateway_request.transactionRequest = TransactionRequestType.new
      gateway_request.transactionRequest.payment = PaymentType.new
    end

    def charge(args)
      gateway_request.transactionRequest.amount = args[:amount]
      gateway_request.transactionRequest.payment.creditCard = CreditCardType.new(args[:card_number], args[:expiry_date], args[:cvv])
      gateway_request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
      post_request
    end

    def post_request
      gateway_transaction.create_transaction(gateway_request)
    end

    def refund

      gateway_request.transactionRequest.amount = 22.22
      gateway_request.transactionRequest.refTransId = '60169114237'
      gateway_request.transactionRequest.payment.creditCard = CreditCardType.new("4242","XXXX")
      gateway_request.transactionRequest.transactionType = TransactionTypeEnum::RefundTransaction
      post_request
    end

    def handle_charge_response(response)
      handle_response(response)
    end

    private

    def handle_response(response)
      if !response.nil?
        if response.messages.resultCode == MessageTypeEnum::Ok
          if !response.transactionResponse.nil? && !response.transactionResponse.messages.nil?
            puts "Successful charge (auth + capture) (authorization code: #{response.transactionResponse.authCode})"
            puts "Transaction ID: #{response.transactionResponse.transId}"
            puts "Transaction Response Code: #{response.transactionResponse.responseCode}"
            puts "Code: #{response.transactionResponse.messages.messages[0].code}"
            puts "Description: #{response.transactionResponse.messages.messages[0].description}"
          else
            puts 'Transaction Failed'
            if !response.transactionResponse.errors.nil?
              puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
              puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
            end
            raise 'Failed to charge card.'
          end
        else
          puts 'Transaction Failed'
          if !response.transactionResponse.nil? && !response.transactionResponse.errors.nil?
            puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
            puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
          else
            puts "Error Code: #{response.messages.messages[0].code}"
            puts "Error Message: #{response.messages.messages[0].text}"
          end
          raise 'Failed to charge card.'
        end
      else
        puts 'Response is null'
        raise 'Failed to charge card.'
      end

      return response
    end

    def gateway_api_transaction_key
      payment_gateway.client_secret
    end

    def gateway_api_login_id
      payment_gateway.client_id
    end
  end
end
