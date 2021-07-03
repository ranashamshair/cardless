class Admin::RewardInfoController < AdminBaseController
  before_action :set_reward_info, only: %i[edit update destroy]

  def index
    @pagy, @rewards_info = pagy(RewardInfo.all)
  end

  def new
    @reward_info = RewardInfo.new
  end

  def edit
  end

  def create
    @reward_info = RewardInfo.new(reward_info_params)
    respond_to do |format|
      if @reward_info.save
        format.html { redirect_to admin_reward_info_index_path, notice: 'Reward Amount was successfully added.' }
        format.json { render :show, status: :ok, location: @reward_info }
      else
        format.html { render :edit }
        format.json { render json: @reward_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @reward_info.update(reward_info_params)
        format.html { redirect_to admin_reward_info_index_path, notice: 'Reward Amount was successfully updated.' }
        format.json { render :show, status: :ok, location: @reward_info }
      else
        format.html { render :edit }
        format.json { render json: @reward_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reward_info.destroy
    respond_to do |format|
      format.html { redirect_to admin_reward_info_index_path, notice: 'Reward Amount was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_reward_info
    @reward_info = RewardInfo.find(params[:id])
  end

  def reward_info_params
    params.require(:reward_info).permit(:amount)
  end
end
