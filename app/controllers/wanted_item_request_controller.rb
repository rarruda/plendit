class WantedItemRequestController < ApplicationController

  def index

  end


  def create
    render plain: params[:wanted_item_request].inspect
  end

end
