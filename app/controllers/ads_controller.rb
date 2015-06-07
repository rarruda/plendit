class AdsController < ApplicationController
  before_action :set_ad, only: [:show, :preview, :edit, :update, :destroy]
  after_action  :notify_user, only: [:create, :update]
  before_filter :authenticate_user!, :except => [:show, :index, :search]

  # GET /ads
  # GET /ads.json
  def index
    redirect_to :root
  end

  # GET /ads/search
  ## GET /ads.json
  def search
    @supress_footer = true

    @term = params[:q]

    # will need to add search in tags too:
    # as well some sort of ordering/ranking, and support for more complex searches/filters.
    @ads = Ad.where('LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)', "%#{params[:q]}%", "%#{params[:q]}%" ) #kaminari_paginate: .page(page).per(5)

    # fixme: use lng rather than lon everywhere?
    # fixme: center from query param, or a sensible default from a config
    @location_info = {
      center: {lat: 59.913869, lon: 10.752245},
      hits: @ads.map do |ad|
        if not ad.location.nil?
          {id: ad[:id], lat: ad.location[:lat], lon: ad.location[:lon]}
        else
          logger.error "Location not found for ad_id: #{ad.id}"
          nil
        end
      end
    }.to_json.html_safe

    respond_to do |format|
      format.html

      # fixme: should also include ad_url field, generated from router
      format.json {
        render json: @ads,
          except: [:created_at, :updated_at, :tags, :location_id, :user_id],
          include: {
            :user => {:only => [:name, :image_url] },
            :location => {:only => [:lat, :lon] }}
      }
    end
  end

  # GET /users/ads
  def list
    @ads = Ad.where( user_id: view_context.get_current_user_id ).all
  end

  # GET /ads/1
  # GET /ads/1.json
  def show
    @ad_is_favorite = ( user_signed_in? and @ad.is_favorite_of( view_context.get_current_user_id ) )
  end

  # GET /ads/1/preview
  def preview
  end


  # GET /ads/new
  def new
    @ad_types = [
      {
        title: "Stort og smått",
        text: "Stort og smått asdf asdf asdf",
        type: "bap"
      },
      {
        title: "Kjøretøy",
        text: "Kjøretøy asdf asdf asdf",
        type: "veichle"
      },
      {
        title: "Eiendom",
        text: "Eiendom asdf asdf asdf",
        type: "realestate"
      }
    ]
  end

  def create
    # todo: verify for sane ad type
    type = params[:ad_type]
    @ad = Ad.new(user_id: current_user.id)
    # @ad = Ad.new(type: type)
    if @ad.save
      redirect_to edit_users_ad_path(@ad), notice: 'Ad was successfully created.'
    else
      redirect_to new_ad_path, notice: "Couldn't create ad!"
    end
  end

  # GET /ads/1/edit
  def edit
  end

  # # POST /ads
  # # POST /ads.json
  # def create
  #   @ad = Ad.new(ad_params)
  #   @ad.user_id = view_context.get_current_user_id

  #   respond_to do |format|
  #     if @ad.save
  #       format.html { redirect_to ad_images_path(:ad_id => @ad.id), notice: 'Ad was successfully created.' }
  #       format.json { render :show, status: :created, location: @ad }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @ad.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /ads/1
  # PATCH/PUT /ads/1.json
  def update
    respond_to do |format|
      if @ad.update(ad_params)
        format.html { redirect_to edit_users_ad_path(@ad), notice: 'Ad was successfully updated.' }
        format.json { render :show, status: :ok, location: @ad }
      else
        format.html { render :edit }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ads/1
  # DELETE /ads/1.json
  def destroy
    @ad.destroy
    respond_to do |format|
      format.html { redirect_to ads_url, notice: 'Ad was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad
      @ad = Ad.find(params[:id])
    end

    # Callback to create a user notification when an ad has been created/edited.
    def notify_user
      Notification.new(
        user_id: view_context.get_current_user_id,
        message: "Your ad has been inserted and/or updated",
        notification_status_id: 1,
        notifiable: @ad).save
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_params
      params.require(:ad).permit(:title, :location_id, :body, :price, :tags)
    end
end
