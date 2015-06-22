class AdsController < ApplicationController
  before_action :set_ad, only: [:show, :preview, :pause, :stop, :submit_for_review, :resume, :edit, :update, :double_calendar, :single_calendar, :gallery]
  before_filter :authenticate_user!,    :except => [:show, :index, :search, :double_calendar, :single_calendar, :gallery]
  before_filter :require_authorization, :except => [:show, :index, :search, :create, :new, :list, :double_calendar, :single_calendar, :gallery]
  after_action  :notify_user, only: [:create, :update]

  # GET /ads
  # GET /ads.json
  def index
    redirect_to :root
  end

  # GET /ads/search
  ## GET /ads.json
  def search
    @hide_search_field = true
    @supress_footer = true

    @term = params[:q]

    # will need to add search in tags too:
    # as well some sort of ordering/ranking, and support for more complex searches/filters.
    if params.has_key?('q')
      @ads = Ad.search params[:q]  #kaminari_paginate: .page(page).per(5)
    else
      @ads = Ad.limit(10)
    end

    # fixme: use lng rather than lon everywhere?
    # fixme: center from query param, or a sensible default from a config
    @location_info = {
      center: {lat: 59.913869, lon: 10.752245},
      hits: @ads.map do |ad|
        if not ad.geo_location.nil?
          {id: ad[:id], location: { lat: ad.geo_location[:lat], lon: ad.geo_location[:lon] }}
        else
          logger.error "Location not found for ad_id: #{ad.id}"
          nil
        end
      end
    }.to_json.html_safe

    respond_to do |format|
      format.html

      format.json {
        # this all feels quite dirty
        result_markup = render_to_string partial: "search_result_item", collection: @ads, as: 'ad', formats: [:html]
        result_json = @ads.as_json

        render json: {
          hits: result_json,
          markup: result_markup
        }
      }
    end
  end

  # GET /ads/1/gallery
  def gallery
  end


  # GET /users/ads
  def list
    @ads = Ad.for_user( current_user ).all
  end

  # GET /ads/1
  # GET /ads/1.json
  def show
  end

  # GET /ads/1/preview
  def preview
  end

  # GET /ads/1/pause
  def pause
    if @ad.pause!
      redirect_to @ad, notice: 'Ad was successfully paused.'
    else
      redirect_to @ad, notice: 'Ad was NOT paused.'
    end
  end

  # GET /ads/1/stop
  def stop
    if @ad.stop!
      redirect_to @ad, notice: 'Ad was successfully paused.'
    else
      redirect_to @ad, notice: 'Ad was NOT stopped.'
    end
  end

  # GET /ads/1/resume
  def resume
    if @ad.resume!
      redirect_to @ad, notice: 'Ad was successfully resumed.'
    else
      redirect_to @ad, notice: 'Ad was NOT resumed.'
    end
  end

  # GET /ads/1/submit_for_review
  def submit_for_review
    if @ad.submit_for_review!
      redirect_to @ad, notice: 'Ad was successfully submited for review.'
    else
      redirect_to @ad, notice: 'Ad was NOT submited for review.'
    end
  end

  # GET /ads/new
  def new
    @ad_types = [
      {
        title: "Stort og smått",
        type: "bap",
        image: "new_realestate.png"
      },
      {
        title: "Kjøretøy",
        type: "veichle",
        image: "new_realestate.png"
      },
      {
        title: "Eiendom",
        type: "realestate",
        image: "new_realestate.png"
      }
    ]
  end

  # GET /ads/1/double_calendar?date=day_or_month
  def double_calendar
    if params[:date].nil?
      date = Date.today
    else
      date = params[:date].to_date
    end
    render "shared/_double_pageable_calendar", layout: false, locals: { date: date, ad: @ad }
  end

  # GET /ads/1/single_calendar?date=day_or_month
  def single_calendar
    if params[:date].nil?
      date = Date.today
    else
      date = params[:date].to_date
    end
    render "shared/_single_pageable_calendar", layout: false, locals: { date: date, ad: @ad }
  end

  # POST /ads
  # POST /ads.json
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


  # PATCH/PUT /ads/1
  # PATCH/PUT /ads/1.json
  def update
    ad_params_local = ad_params
    # Only Add a new address if the address_line and post_code have data:
    if params['use_registered_location'] == '1'
      ad_params_local.except! 'location_attributes'
    else
      ad_params_local['location_attributes']['user_id'] = current_user.id
      ad_params_local['location_attributes']['city'] = Location.city_from_postal_code ad_params_local['location_attributes']['post_code']
    end

    #logger.debug "ad_params_local>> #{ad_params_local}"
    respond_to do |format|
      if @ad.update(ad_params_local)
        format.html { redirect_to edit_users_ad_path(@ad), notice: 'Ad was successfully updated.' }
        format.json { render :show, status: :ok, location: @ad }
      else
        format.html { render :edit }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad
      @ad = Ad.find(params[:id])
    end

    def require_authorization
      if not ( ( @ad and @ad.user == current_user ) or
        current_user.status == 'admin' )
        # throw exception. User not allowed here.
        logger.tagged("user_id:#{current_user.id}") {
          logger.error "User not authorized to see this page."
        }
        raise "User not authorized to see this page."
      end
    end

    # Callback to create a user notification when an ad has been created/edited.
    def notify_user
      Notification.new(
        user_id: current_user.id,
        message: "Your ad has been inserted and/or updated",
        notifiable: @ad).save
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_params
      params.require(:ad).permit(:title, :body, :price, :tag_list, :location_id, :location_attributes => [:address_line, :post_code] )
    end
end
