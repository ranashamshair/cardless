include AuthorizeNet::API
module Payment
  class AuthorizePay < Gateway

    attr_reader :transaction, :request

    def initialize(payment_gateway = nil)
      api_login_id = api_login_id(payment_gateway) # '3DTub79c'
      api_transaction_key = api_transaction_key(payment_gateway) # '5w2tXY47wR97VnNk'
      environment = sandbox

      @transaction = AuthorizeNet::API::Transaction.new(api_login_id, api_transaction_key, gateway: environment)
      @request = CreateTransactionRequest.new
      request.transactionRequest = TransactionRequestType.new
      request.transactionRequest.payment = PaymentType.new
    end

    def charge(args)
      amount = args[:amount] # 22.22
      card_number = args[:card_number] # 4242424242424242
      expiry_date = args[:expiry_date] # 0728
      card_cvv = args[:cvv] # 123
      request.transactionRequest.amount = amount
      request.transactionRequest.payment.creditCard = CreditCardType.new(card_number, expiry_date, card_cvv)
      request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
      post_request
    end

    def post_request
      transaction.create_transaction(request)
    end

    def refund

      request.transactionRequest.amount = 22.22
      request.transactionRequest.refTransId = '60169114237'
      request.transactionRequest.payment.creditCard = CreditCardType.new("4242","XXXX")
      request.transactionRequest.transactionType = TransactionTypeEnum::RefundTransaction
      post_request
    end

    def handle_charge_response(response)
      handle_response(response)
    end

    private

    def handle_response(response)
      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          if response.transactionResponse != nil && response.transactionResponse.messages != nil
            puts "Successful charge (auth + capture) (authorization code: #{response.transactionResponse.authCode})"
            puts "Transaction ID: #{response.transactionResponse.transId}"
            puts "Transaction Response Code: #{response.transactionResponse.responseCode}"
            puts "Code: #{response.transactionResponse.messages.messages[0].code}"
            puts "Description: #{response.transactionResponse.messages.messages[0].description}"
          else
            puts 'Transaction Failed'
            if response.transactionResponse.errors != nil
              puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
              puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
            end
            raise 'Failed to charge card.'
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
          raise 'Failed to charge card.'
        end
      else
        puts 'Response is null'
        raise 'Failed to charge card.'
      end

      return response
    end

    def api_transaction_key(payment_gateway)
      payment_gateway.client_secret
    end

    def api_login_id(payment_gateway)
      payment_gateway.client_id
    end

  end
end