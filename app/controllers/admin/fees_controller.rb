class Admin::FeesController < AdminBaseController
  def index
    @fee = Fee.first
    @fee = Fee.new if @fee.blank?
    @url = admin_fee_path(@fee) if @fee.id.present?
    @url = admin_fees_path if @fee.id.blank?
  end

  def create
    @fee = Fee.new(fee_params)
    if @fee.save
      redirect_to admin_fees_path
    else
      redirect_to admin_fees_path
    end
  end

  def update
    @fee = Fee.find(params[:id])
    if @fee.update(fee_params)
      redirect_to admin_fees_path
    else
      redirect_to admin_fees_path
    end
  end

  private

  def fee_params
    params.fetch(:fee).permit(:sale, :withdraw, :reserve, :days)
  end
end
