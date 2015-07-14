class AdImagesController < ApplicationController
  before_action :set_ad_image, only: [:update, :destroy, :make_primary]
  before_filter :authenticate_user!

  # GET /ad_images
  # GET /ad_images.json
  def index
    # missing verification if user owns ad:
    @ad = Ad.find(params[:ad_id])
    @ad_id = params[:ad_id]
    @ad_images = AdImage.for_ad_id( params[:ad_id] ).all
    respond_to do |format|
      format.html {
        render :index
      }
      format.json {
        render :json => @ad_images.collect { |p| p.to_dropzone_gallery }.to_json
      }
    end
  end

  # POST /ad_images
  # POST /ad_images.json
  def create
    @ad_image = AdImage.new(ad_image_params)
    @ad_image.make_primary
    respond_to do |format|
      if @ad_image.save
        format.json { render json: @ad_image.to_dropzone_gallery.to_json, :status => 200 }
        format.html { redirect_to @ad_image, notice: 'Ad image was successfully added.'}
      else
        #  you need to send an error header, otherwise Dropzone
        #  will not interpret the response as an error:
        format.json { render json: { error: @ad_image.errors.full_messages.join(',')}, :status => 400 }
        format.html { redirect_to @ad_image, notice: 'Ad image had issues being created.'}
      end
    end
  end

  # PATCH/PUT /ad_images/1
  # PATCH/PUT /ad_images/1.json
  def update
    respond_to do |format|
      if @ad_image.update(ad_image_params)
        format.html {
          if params[:ad_image][:previous_url]
            redirect_to params[:ad_image][:previous_url], notice: 'Ad item was successfully updated.'
          else
            redirect_to @ad_image, notice: 'Ad item was successfully updated.'
          end
        }
        #format.json { render :show, status: :ok, location: @ad_image }
        format.json { head :no_content }
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
      format.html { redirect_to ad_images_path, notice: 'Ad image was successfully destroyed.' }
      format.json { render json: { message: "successfully destroyed" }, :status => 200 }
    end
  end

  def make_primary
    @ad_image.make_primary
    respond_to do |format|
      format.html { redirect_to (users_ad_ad_images_path @ad_image.ad), notice: 'Ad image was made primary.' }
      format.json { render json: { message: "successfully made primary" }, :status => 200 }
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
