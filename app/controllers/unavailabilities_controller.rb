class UnavailabilitiesController < ApplicationController
  before_action :set_ad

  def index
  end

  def create
    unavailability = @ad.unavailabilities.build(unavailabilty_params)
    unavailability.save
    redirect_to ad_unavailabilities_path @ad
  end

  def destroy
    u = Unavailability.find(params[:id])
    u.destroy
    redirect_to ad_unavailabilities_path @ad
  end

  private

  def set_ad
    @ad = Ad.find(params[:ad_id])
  end

  def unavailabilty_params
    params.require(:unavailability).permit(:from_date, :to_date)
  end
end
