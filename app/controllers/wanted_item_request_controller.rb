class WantedItemRequestController < ApplicationController

  def index
    @requests = WantedItemRequest.all
  end

  def create
    @wanted_item_request = WantedItemRequest.new(wanted_item_request_params)
    if user_signed_in?
      @wanted_item_request.user = current_user
    end
    @wanted_item_request.save
    redirect_to users_wanted_item_request_index_path
  end

  def thanks

  end

  private

  def wanted_item_request_params
    params.require(:wanted_item_request).permit(:description, :place, :email)
  end

end
