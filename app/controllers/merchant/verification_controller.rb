class Merchant::VerificationController < MerchantBaseController
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
          format.html { redirect_to contact_details_merchant_verification_index_path}
        else
          format.html { redirect_to company_info_merchant_verification_index_path }
        end
      else
        @company.user_id = current_user.id
        if @company.save
          format.html { redirect_to contact_details_merchant_verification_index_path}
        else
          format.html { redirect_to company_info_merchant_verification_index_path }
        end
      end

    end
  end

  def contact_details
    @company = current_user.company
  end

  def save_contact_details
    @company = Company.find(params[:company][:id])
    respond_to do |format|
      if @company.update(contact_details_params)
        @company.update(phone: params[:company][:full_phone])
        format.html { redirect_to brand_info_merchant_verification_index_path}
      else
        format.html { redirect_to contact_details_merchant_verification_index_path }
      end
    end
  end

  def brand_info
    @company = current_user.company
  end

  def save_brand_info
    @company = Company.find(params[:company][:id])
    respond_to do |format|
      if @company.update(brand_info_params)
        format.html { redirect_to bank_details_merchant_verification_index_path}
      else
        format.html { redirect_to brand_info_merchant_verification_index_path }
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
          format.html { redirect_to verify_bank_merchant_verification_index_path(id: @bank) }
        else
          format.html { redirect_to bank_details_merchant_verification_index_path }
        end
      else
        @bank.user_id = current_user.id
        @bank.status = :active
        if @bank.save
          format.html { redirect_to verify_bank_merchant_verification_index_path(id: @bank)}
        else
          format.html { redirect_to bank_details_merchant_verification_index_path }
        end
      end

    end
  end

  def verify_bank
    @bank = Bank.find(params[:id])
  end

  def verification_status
    @company = current_user.company
  end

  def complete_verification
    @company = current_user.company
    respond_to do |format|
      if @company.update(docs_params)
        format.html { redirect_to thankyou_merchant_verification_index_path }
      else
        format.html { redirect_to verification_status_merchant_verification_index_path }
      end
    end
  end

  def thankyou
  end


  private

  def company_info_params
    params.require(:company).permit(:country, :city, :postcode, :address, :business_type, :industry, :buisness_work, :name, :vat)
  end

  def contact_details_params
    params.require(:company).permit(:support_email, :phone, :website)
  end

  def brand_info_params
    params.require(:company).permit(:logo)
  end

  def bank_details_params
    params.require(:bank).permit( :user_name, :bank_name, :country, :iban)
  end

  def docs_params
    params.require(:company).permit(:id_doc, :legal_doc, :legal_doc_type)
  end
end
