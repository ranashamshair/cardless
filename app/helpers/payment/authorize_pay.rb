include AuthorizeNet::API
module Payment
  class AuthorizePay < Gateway

    attr_reader :gateway_transaction, :gateway_request

    def initialize
      api_login_id = gateway_api_login_id
      api_transaction_key = gateway_api_transaction_key
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
      response_to_return = { message: 'something went wrong', charge: nil, error_code: "unknown #{payment_gateway.id} #{payment_gateway.gateway_type}", response: '' }

      if !response.nil?
        if response.messages.resultCode == MessageTypeEnum::Ok
          if !response.transactionResponse.nil? && !response.transactionResponse.messages.nil?
            charge_response = {
              authorization_code: response.transactionResponse.authCode,
              charge_id: response.transactionResponse.transId,
              response_code: response.transactionResponse.responseCode,
              message_code: response.transactionResponse.messages.messages[0].code,
              detail_description: response.transactionResponse.messages.messages[0].description
            }
            response_to_return = { message: nil,charge: response.transactionResponse.transId,error_code: nil, response: charge_response.to_json }
          else
            if !response.transactionResponse.errors.nil?
              failure_response = {
                message: response.transactionResponse.errors.errors[0].errorText,
                error_code: response.transactionResponse.errors.errors[0].errorCode
              }
              response_to_return = { message: response.transactionResponse.errors.errors[0].errorText, charge: nil, error_code: response.transactionResponse.errors.errors[0].errorCode, response: failure_response.to_json }
            end
          end
        else
          puts 'Transaction Failed'
          if !response.transactionResponse.nil? && !response.transactionResponse.errors.nil?
            failure_response = {
              message: response.transactionResponse.errors.errors[0].errorText,
              error_code: response.transactionResponse.errors.errors[0].errorCode
            }
            response_to_return = { message: response.transactionResponse.errors.errors[0].errorText, charge: nil, error_code: response.transactionResponse.errors.errors[0].errorCode, response: failure_response.to_json }
          else
            failure_response = {error_code: response.messages.messages[0].code, message: response.messages.messages[0].text}
            response_to_return = { message: response.messages.messages[0].text, charge: nil, error_code: response.messages.messages[0].code, response: failure_response.to_json }
          end
        end
      end
      return response_to_return
    end

    def gateway_api_transaction_key
      # '5w2tXY47wR97VnNk'
      payment_gateway.client_secret
    end

    def gateway_api_login_id
      # '3DTub79c'
      payment_gateway.client_id
    end
  end
end
