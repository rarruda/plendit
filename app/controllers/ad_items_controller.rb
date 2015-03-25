class AdItemsController < ApplicationController
  before_action :set_ad_item, only: [:show, :edit, :update, :destroy]

  # GET /ad_items
  # GET /ad_items.json
  def index
    @ad_items = AdItem.all
  end

  # GET /ad_items/1
  # GET /ad_items/1.json
  def show
  end

  # GET /ad_items/new
  def new
    @ad_item = AdItem.new
  end

  # GET /ad_items/1/edit
  def edit
  end

  # POST /ad_items
  # POST /ad_items.json
  def create
    @ad_item = AdItem.new(ad_item_params)

    respond_to do |format|
      if @ad_item.save
        format.html { redirect_to @ad_item, notice: 'Ad item was successfully created.' }
        format.json { render :show, status: :created, location: @ad_item }
      else
        format.html { render :new }
        format.json { render json: @ad_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ad_items/1
  # PATCH/PUT /ad_items/1.json
  def update
    respond_to do |format|
      if @ad_item.update(ad_item_params)
        format.html { redirect_to @ad_item, notice: 'Ad item was successfully updated.' }
        format.json { render :show, status: :ok, location: @ad_item }
      else
        format.html { render :edit }
        format.json { render json: @ad_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ad_items/1
  # DELETE /ad_items/1.json
  def destroy
    @ad_item.destroy
    respond_to do |format|
      format.html { redirect_to ad_items_url, notice: 'Ad item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad_item
      @ad_item = AdItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_item_params
      params.require(:ad_item).permit(:ad_id)
    end
end
