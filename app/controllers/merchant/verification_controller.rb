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
  end

  def contact_details
  end

  def brand_info
  end

  def bank_details
  end

  def verify_bank
  end

  def verification_status
  end

end
