class FavoriteListsController < InheritedResources::Base

  private

    def favorite_list_params
      params.require(:favorite_list).permit(:user_id, :name)
    end
end

