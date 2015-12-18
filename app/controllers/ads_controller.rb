class AdsController < ApplicationController
  include MapViewRememberable

  before_action :set_ad, only: [
    :ad_image,
    :approve,
    :destroy,
    :edit,
    :edit_availability,
    :gallery,
    :image_manager,
    :nested_images,
    :pause,
    :preview,
    :resume,
    :show,
    :stop,
    :submit_for_review,
    :suspend,
    :unavailability,
    :unpublish_and_edit,
    :update
  ]

  before_action :authenticate_user!, :except => [
    :gallery,
    :index,
    :search,
    :show,
    :unavailability
  ]

  before_action :require_authorization, :except => [
    :create,
    :gallery,
    :index,
    :list,
    :new,
    :search,
    :show,
    :unavailability
  ]

  after_action :notify_about_approval, only: [ :approve ]

  # its just confusing to have the chat in the search page:
  skip_after_filter :intercom_rails_auto_include, only: [ :search ]


  # GET /ads
  # GET /ads.json
  def index
    redirect_to :root
  end

  # GET /ads/search
  ## GET /ads.json
  def search
    @page_has_maps = true
    @hide_search_field = true
    @supress_footer = true
    @ad_categories = Rails.configuration.x.ads.categories
    @ad_categories.map! { |e| OpenStruct.new(e) }

    query  = params[:q]
    filter = []

    @map_bounds = get_search_bounds params

    options = params.select { |k,v| ['price_min','price_max', 'category'].include? k }.keep_if { |k,v| not v.blank? }
    options[:category].reject!(&:blank?) if options.has_key? :category
    options.delete(:category) if options.has_key?(:category) && options[:category].empty?

    options = options.merge(@map_bounds)

    # Safely transform hash in array:
#    if options[:category].is_a? Hash
#      options[:category] = options[:category].keys.keep_if{ |e| ['bap','motor','realestate'].include? e }
#    end

    @ads = Ad.search( query, filter, options).page( params[:page] ).results

    @term = params[:q]
    @selected_category = params[:category]

    @result_json = render_to_string( formats: 'json' ).html_safe
    @result_markup = render_to_string partial: 'search_result_box', formats: [:html]

    respond_to do |format|
      format.html
      format.json
    end

    save_map_bounds @map_bounds
  end

  # GET /ads/1/gallery
  def gallery
  end


  # GET /me/ads
  def list
    @ads = Ad.for_user( current_user ).all.decorate
  end

  # GET /ads/1
  # GET /ads/1.json
  def show
    @page_has_maps = true
    @page_needs_no_footer_padding = true
    if not ad_can_be_shown?
      render status: 404, text: "Fixme: Annonsen finnes ikke eller er ikke offentlig"
    end
  end

  # GET /ads/1/preview
  def preview
  end

  # POST /ads/1/pause
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

  # POST /ads/1/submit_for_review
  def submit_for_review
    if @ad.submit_for_review!
      redirect_to @ad
    else
      redirect_to @ad, alert: 'Ad was NOT submited for review.'
    end
  end

  # POST /ads/1/approve
  def approve
    if @ad.approve!
      redirect_to @ad
    else
      redirect_to @ad, alert: 'Ad was NOT approved.'
    end
  end

  # POST /ads/1/suspend
  def suspend
    if @ad.suspend!
      redirect_to '/'
    else
      redirect_to @ad, alert: 'Ad was NOT suspended.'
    end
  end

  # DELETE /ads/1
  # DELETE /ads/1.json
  def destroy
    if @ad.delete
      redirect_to users_path
    else
      redirect_to @ad, alert: 'Ad was NOT deleted.'
    end
  end

  # GET /ads/new
  def new
    @ad_categories = Rails.configuration.x.ads.categories
    @ad_categories.map! { |e| OpenStruct.new(e) }
  end

  def ad_image
    img = AdImage.new(ad_image_params)
    @ad.ad_images.push img
    img.make_primary
    @ad.save
    head :created
  end

  def image_manager
     render partial: "shared/image_manager_item", collection: @ad.ad_images, as: :ad_image
  end

  def nested_images
    render layout: false
  end

  # GET /ads/1/availability
  def unavailability
    if params[:start_date].nil?
      start_date = Date.today
    else
      start_date = params[:start_date].to_date
    end
    # FIXME: add support for: end_date
    #
    render partial: "ads/unavailability", locals: { start_date: start_date, ad: @ad }
  end

  # POST /ads
  # POST /ads.json
  def create
    LOG.error "Ad Category sent is not supported. This is not ok." if not Ad.categories.include? params[:category]
    # FIXME: do something about it if there was an error with the category...

    @ad = Ad.new(user_id: current_user.id,
      category: params[:category],
      location: current_user.favorite_location
    )

    if @ad.save
      redirect_to edit_users_ad_path(@ad)
    else
      LOG.error "Error saving ad upon creation: #{@ad.errors.inspect}", { user_id: current_user.id }
      redirect_to new_ad_path, alert: "Annonsen kunne ikke opprettes!"
    end
  end

  # GET /ads/1/edit
  def edit
  end

  def edit_availability
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

    # remove registration_number from all not motor categories.
    ad_params_local.except! 'registration_number' unless @ad.category == 'motor'

    # remove changes to ad images that no longer exists.
    # fixes that we try deleiting non-extant stuff if you hit
    # ctrl-r on the edit page after having already submitted stuff.
    if ad_params_local.has_key? :ad_images_attributes
      ad_params_local[:ad_images_attributes].delete_if do |k, v|
        v.has_key?(:id) && !@ad.ad_images.exists?(id: v[:id])
      end
    end

    @ad.assign_attributes(ad_params_local)

    @ad.valid? # we do this for side effects, so next line does something.
    @error_markup = render_to_string partial: 'ad_input_errors', formats: [:html]

    #LOG.debug "ad_params_local>> #{ad_params_local}"
    respond_to do |format|
      if @ad.save(validate: false)
        format.html { render :edit }
        format.json
      else
        format.html { render :edit }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  def unpublish_and_edit
    # no need to force to draft status, if the ad is already it.
    if @ad.draft? || @ad.edit!
      redirect_to edit_ad_path(@ad)
    else
      redirect_to @ad, alert: 'Ad was set to editing suspended.'
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad
      @ad = Ad.find(params[:id]).decorate
    end

    def require_authorization
      if not ( ( @ad and @ad.user == current_user ) or current_user.is_site_admin? )
        # throw exception. User not allowed here.
        LOG.error "User not authorized to see this page.", { ad_id: @ad.id, user_id: current_user.id }
        raise "User not authorized to see this page."
      end
    end

    def notify_about_approval
      Notification.new(
        user_id: @ad.user.id,
        message: "Annonsen din \"#{@ad.display_title}\" er nå godkjent og publisert",
        notifiable: @ad).save
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_params
      params.require(:ad).permit( :title, :body, :price_in_h, :tag_list,
        :registration_number, :registration_group, :location_id,
        :estimated_value_in_h, :boat_license_required,
        location_attributes:    [ :address_line, :post_code, :id ],
        payin_rules_attributes: [ :payin_amount_in_h, :unit, :effective_from, :id, :_destroy ],
        ad_images_attributes:   [ :image, :weight, :description, :id, :_destroy ]
      )
    end

    def ad_image_params
      params.require(:ad_image).permit(:image)
    end

    def ad_can_be_shown?
      @ad.status == 'published' ||
      user_signed_in? && (current_user.is_site_admin? || current_user == @ad.user)
    end

end
