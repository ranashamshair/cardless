class Merchant::VerificationController < MerchantBaseController
  include ApplicationHelper
  layout 'verification'
  def index
  end

  def company_info
    if current_user.company.present?
      @company = current_user.company
    else
      @company = Company.new
    end
  end

  def save_company_detail
    if params[:company][:id].present?
      @company = Company.find(params[:company][:id])
    else
      @company  = Company.new(company_info_params)
    end
    respond_to do |format|
      if @company.id.present?
        if @company.update(company_info_params)
          begin
            @client = Twilio::REST::Client.new('AC2877490025f56ffc028b9f9054be4ff0', 'e94557ebdb4d74257be5fc32f1b8bd74')
            verification_check = @client.verify.services('VA8883c2d787b2f9375ac86302f40104c4').verification_checks.create(to: params[:company][:full_phone], code: params[:otp])
            status = verification_status.status
          rescue
            status = "pending"
          end
          if status == "pending"
            check = verify_phone_number(params[:company][:full_phone])
            if check["valid"]
              status = "approved"
            else
              status = "pending"
            end
          end

          if status == "approved"
            @company.update(phone: params[:company][:full_phone])
            format.html { redirect_to bank_details_merchant_verification_index_path}
          else
            @company.update(phone: nil)
            format.html { redirect_to company_info_merchant_verification_index_path, notice: "OTP is wrong!"}
          end
        else
          format.html { redirect_to company_info_merchant_verification_index_path }
        end
      else
        @company.user_id = current_user.id
        if @company.save
          begin
            @client = Twilio::REST::Client.new('AC2877490025f56ffc028b9f9054be4ff0', 'e94557ebdb4d74257be5fc32f1b8bd74')
            verification_check = @client.verify.services('VA8883c2d787b2f9375ac86302f40104c4').verification_checks.create(to: params[:company][:full_phone], code: params[:otp])
            status = verification_status.status
          rescue
            status = "pending"
          end
          if status == "pending"
            check = verify_phone_number(params[:company][:full_phone])
            if check["valid"]
              status = "approved"
            else
              status = "pending"
            end
          end
          if verification_check.status == "approved"
            @company.update(phone: params[:company][:full_phone])
            format.html { redirect_to bank_details_merchant_verification_index_path}
          else
            @company.update(phone: nil)
            format.html { redirect_to company_info_merchant_verification_index_path, notice: "OTP is wrong!"}
          end
        else
          format.html { redirect_to company_info_merchant_verification_index_path }
        end
      end

    end
  end

  def bank_details
    if current_user.banks.first.present?
      @bank = current_user.banks.first
    else
      @bank = Bank.new
    end
  end

  def save_bank_details
    if params[:bank][:id].present?
      @bank = Bank.find(params[:bank][:id])
    else
      @bank  = Bank.new(bank_details_params)
    end
    respond_to do |format|
      if @bank.id.present?
        if @bank.update(bank_details_params)
          format.html { redirect_to verification_status_merchant_verification_index_path }
        else
          format.html { redirect_to bank_details_merchant_verification_index_path }
        end
      else
        @bank.user_id = current_user.id
        @bank.status = :active
        if @bank.save
          format.html { redirect_to verification_status_merchant_verification_index_path}
        else
          format.html { redirect_to bank_details_merchant_verification_index_path }
        end
      end

    end
  end

  def verification_status
    @company = current_user.company
  end

  def complete_verification
    @company = current_user.company
    respond_to do |format|
      if @company.update(docs_params)
        NotificationMailer.thankyou_email(current_user).deliver_now
        format.html { redirect_to thankyou_merchant_verification_index_path }
      else
        format.html { redirect_to verification_status_merchant_verification_index_path }
      end
    end
  end

  def thankyou
  end


  def verify_phone
    if params[:phone].present?
      @client = Twilio::REST::Client.new('AC2877490025f56ffc028b9f9054be4ff0', 'e94557ebdb4d74257be5fc32f1b8bd74')
      verification = @client.verify.services('VA8883c2d787b2f9375ac86302f40104c4').verifications.create(to: params[:phone].strip, channel: 'sms')
    end
  end

  private

  def company_info_params
    params.require(:company).permit(:country, :city,:support_email, :phone, :website, :postcode, :address, :business_type, :industry, :buisness_work, :name, :vat)
  end


  def bank_details_params
    params.require(:bank).permit( :user_name, :bank_name, :country, :iban)
  end

  def docs_params
    params.require(:company).permit(:id_doc, :legal_doc, :legal_doc_type,:logo)
  end
end
