include AuthorizeNet::API
module Payment
  class AuthorizePay

    attr_reader :api_login_id, :api_transaction_key, :environment, :transaction, :request, :response

    def initialize(payment_gateway = nil)
      @api_login_id = '3DTub79c'
      @api_transaction_key = '5w2tXY47wR97VnNk'
      @environment = 'sandbox'.to_sym

      @transaction = AuthorizeNet::API::Transaction.new(api_login_id, api_transaction_key, :gateway => environment)
      @request = CreateTransactionRequest.new
      request.transactionRequest = TransactionRequestType.new
      request.transactionRequest.payment = PaymentType.new
      @response = nil
    end

    def charge
      request.transactionRequest.amount = 22.22
      request.transactionRequest.payment.creditCard = CreditCardType.new("4242424242424242","0728","123")
      request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
      post_request
    end

    def post_request
      @response = transaction.create_transaction(request)
      handle_response
    end

    def refund

      request.transactionRequest.amount = 22.22
      # request.transactionRequest.payment = PaymentType.new
      # request.transactionRequest.payment.creditCard = CreditCardType.new('0015','XXXX')
      request.transactionRequest.refTransId = '60169114237'
      request.transactionRequest.payment.creditCard = CreditCardType.new("4242","XXXX")
      request.transactionRequest.transactionType = TransactionTypeEnum::RefundTransaction
      post_request
    end

    def handle_response
      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          if response.transactionResponse != nil && response.transactionResponse.messages != nil
            puts "Successful charge (auth + capture) (authorization code: #{response.transactionResponse.authCode})"
            puts "Transaction ID: #{response.transactionResponse.transId}"
            puts "Transaction Response Code: #{response.transactionResponse.responseCode}"
            puts "Code: #{response.transactionResponse.messages.messages[0].code}"
            puts "Description: #{response.transactionResponse.messages.messages[0].description}"
          else
            puts "Transaction Failed"
            if response.transactionResponse.errors != nil
              puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
              puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
            end
            raise "Failed to charge card."
          end
        else
          puts "Transaction Failed"
          if response.transactionResponse != nil && response.transactionResponse.errors != nil
            puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
            puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
          else
            puts "Error Code: #{response.messages.messages[0].code}"
            puts "Error Message: #{response.messages.messages[0].text}"
          end
          raise "Failed to charge card."
        end
      else
        puts "Response is null"
        raise "Failed to charge card."
      end

      return response
    end

  end
end