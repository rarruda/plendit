class UnavailabilitiesController < ApplicationController
  before_action :set_ad


  def index

  end

  def create
    pp "lololol"
    pp params
  end

  private

  def set_ad
    @ad = Ad.find(params[:ad_id])
  end

end
