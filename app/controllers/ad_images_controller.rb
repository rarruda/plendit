class AdImagesController < ApplicationController
  before_action :set_ad_image, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:show, :index, :search]

  # GET /ad_images
  # GET /ad_images.json
  def index
    @ad_images = AdImage.all.order('id')
  end

  # GET /ad_images/1
  # GET /ad_images/1.json
  def show
  end

  # GET /ad_images/new
  def new
    @ad_image = AdImage.new
  end

  # GET /ad_images/1/edit
  def edit
  end

  # POST /ad_images
  # POST /ad_images.json
  def create
    @ad_image = AdImage.new(ad_image_params)

    respond_to do |format|
      if @ad_image.save
        format.html { redirect_to @ad_image, notice: 'Ad item was successfully created.' }
        format.json { render :show, status: :created, location: @ad_image }
      else
        format.html { render :new }
        format.json { render json: @ad_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ad_images/1
  # PATCH/PUT /ad_images/1.json
  def update
    respond_to do |format|
      if @ad_image.update(ad_image_params)
        format.html { redirect_to @ad_image, notice: 'Ad item was successfully updated.' }
        format.json { render :show, status: :ok, location: @ad_image }
      else
        format.html { render :edit }
        format.json { render json: @ad_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ad_images/1
  # DELETE /ad_images/1.json
  def destroy
    @ad_image.destroy
    respond_to do |format|
      format.html { redirect_to ad_images_url, notice: 'Ad item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad_image
      @ad_image = AdImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_image_params
      params.require(:ad_image).permit(:ad_id, :image, :description, :weight)
    end
end
