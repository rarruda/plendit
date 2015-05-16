class FavoriteAdsController < InheritedResources::Base

  private

    def favorite_ad_params
      params.require(:favorite_ad).permit(:favorite_list_id, :ad_id)
    end
end

