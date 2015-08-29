class AdsController < ApplicationController
  include MapViewRememberable

  before_action :set_ad, only: [
    :approve,
    :double_calendar,
    :edit,
    :gallery,
    :image_manager,
    :pause,
    :preview,
    :resume,
    :show,
    :single_calendar,
    :stop,
    :suspend,
    :submit_for_review,
    :update
  ]

  before_filter :authenticate_user!, :except => [
    :double_calendar,
    :gallery,
    :index,
    :search,
    :show,
    :single_calendar
  ]

  before_filter :require_authorization, :except => [
    :create,
    :double_calendar,
    :gallery,
    :index,
    :list,
    :new,
    :search,
    :show,
    :single_calendar
  ]

  after_action :notify_about_approval, only: [ :approve ]

  # GET /ads
  # GET /ads.json
  def index
    redirect_to :root
  end

  # GET /ads/search
  ## GET /ads.json
  def search
    @include_map = true
    @hide_search_field = true
    @supress_footer = true
    @ad_categories = Rails.configuration.x.ads.categories


    query  = params[:q]
    filter = []
    options = params.select { |k,v| ['ne_lat','ne_lon','sw_lat','sw_lon','price_min','price_max','category'].include? k }.keep_if{ |k,v| not v.blank? }

    # Safely transform hash in array:
#    if options[:category].is_a? Hash
#      options[:category] = options[:category].keys.keep_if{ |e| ['bap','motor','realestate'].include? e }
#    end

    @ads = Ad.search( query, filter, options).page( params[:page] ).results

    @term = params[:q]

    # Load map parameters:
    map_center_lat, map_center_lon, @map_zl = get_map_view( params )
    @map_center = {lat: map_center_lat, lon: map_center_lon }

    logger.debug "search>> sending to view map_center: #{@map_center} map_zl:#{@map_zl}"

    @result_json = render_to_string( formats: 'json' ).html_safe
    @result_markup = render_to_string partial: "search_result_box", formats: [:html]

    respond_to do |format|
      format.html
      format.json
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
    @include_map = true
    if not ad_can_be_shown?
      render status: 404, text: "Fixme: Annonsen finnes ikke eller er ikke offentlig"
    end
  end

  # GET /ads/1/preview
  def preview
  end

  # GET /ads/1/pause
  def pause
    if @ad.pause!
      redirect_to @ad
    else
      redirect_to @ad, alert: 'Ad was NOT paused.'
    end
  end

  # GET /ads/1/stop
  def stop
    if @ad.stop!
      redirect_to @ad
    else
      redirect_to @ad, alert: 'Ad was NOT stopped.'
    end
  end

  # GET /ads/1/resume
  def resume
    if @ad.resume!
      redirect_to @ad
    else
      redirect_to @ad, alert: 'Ad was NOT resumed.'
    end
  end

  # GET /ads/1/submit_for_review
  def submit_for_review
    if @ad.submit_for_review!
      redirect_to @ad
    else
      redirect_to @ad, alert: 'Ad was NOT submited for review.'
    end
  end

  # GET /ads/1/approve
  def approve
    if @ad.approve!
      redirect_to @ad
    else
      redirect_to @ad, alert: 'Ad was NOT approved.'
    end
  end

  # GET /ads/1/suspend
  def suspend
    if @ad.suspend!
      redirect_to '/'
    else
      redirect_to @ad, alert: 'Ad was NOT suspended.'
    end
  end

  # GET /ads/new
  def new
    @ad_categories = Rails.configuration.x.ads.categories
  end

  def image_manager
     render partial: "shared/image_manager_item", collection: @ad.ad_images, as: :ad_image
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
    logger.error "Ad Category sent is not supported. This is not ok." if not Ad.categories.include? params[:category]
    # FIXME: do something about it if there was an error with the category...

    @ad = Ad.new(user_id: current_user.id, category: params[:category],
                 insurance_required: 'yes', location: current_user.favorite_location)

    if @ad.save
      redirect_to edit_users_ad_path(@ad)
    else
      redirect_to new_ad_path, alert: "Couldn't create ad!"
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
    if params['create_new_location'] == '1'
      ad_params_local['location_attributes']['user_id'] = current_user.id
      ad_params_local['location_attributes']['city'] = Location.city_from_postal_code ad_params_local['location_attributes']['post_code']
    else
      ad_params_local.except! 'location_attributes'
    end

    #logger.debug "ad_params_local>> #{ad_params_local}"
    respond_to do |format|
      if @ad.update(ad_params_local)
        format.html { render :edit }
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
      if not ( ( @ad and @ad.user == current_user ) or current_user.is_site_admin? )
        # throw exception. User not allowed here.
        logger.tagged("user_id:#{current_user.id}") {
          logger.error "User not authorized to see this page."
        }
        raise "User not authorized to see this page."
      end
    end

    def notify_about_approval
      Notification.new(
        user_id: @ad.user.id,
        message: "Your ad has been approved. It is now published",
        notifiable: @ad).save
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_params
      params.require(:ad).permit( :title, :body, :price, :tag_list, :insurance_required,
        :location_id, :location_attributes => [:address_line, :post_code] )
    end

    def ad_can_be_shown?
      @ad.status == 'published' ||
      user_signed_in? && (current_user.is_site_admin? || current_user == @ad.user)
    end

end
