class FavoriteAdsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favorite_ad, only: [:create]


  def index
    @favorite_ads = current_user.favorite_ads.decorate
  end

  # POST /favorite_ads
  def create
    if @favorite_ad.nil?
      @favorite_list.favorite_ads.new( ad_id: params[:favorite_ad][:ad_id] )
    else
      @favorite_ad.destroy
    end

    if @favorite_list.save
      redirect_to params[:favorite_ad][:previous_url]
    else
      redirect_to params[:favorite_ad][:previous_url], alert: 'Ad Favorite information was NOT flushed to db.'
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite_ad
      @favorite_list = FavoriteList.find_or_create_by(
        name: 'default',
        user_id: current_user.id
      )
      @favorite_ad = @favorite_list.favorite_ads.find_by( ad_id: params[:favorite_ad][:ad_id] )
    end

    def favorite_ad_params
      params.require(:favorite_ad).permit(:favorite_list_id, :ad_id, :previous_url)
    end
end

