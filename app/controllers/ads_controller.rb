class AdsController < ApplicationController
  before_action :set_ad, only: [:show, :edit, :update, :destroy]

  before_filter :authenticate_user!, :except => [:show, :index, :search]

  # GET /ads
  # GET /ads.json
  def index
    redirect_to :root
    #@ads = Ad.all
  end

  # GET /ads/search
  ## GET /ads.json
  def search
    # will need to add search in tags too:
    # as well some sort of ordering/ranking, and support for more complex searches/filters.
    @ads = Ad.where('LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)', "%#{params[:q]}%", "%#{params[:q]}%" ) #kaminari_paginate: .page(page).per(5)
  end

  # GET /ads/1
  # GET /ads/1.json
  def show
    @ad = Ad.find( params[:id] )
  end


  # GET /ads/new
  def new
    @ad = Ad.new
  end

  # GET /ads/new1
  def new1
    @ad = Ad.new
  end

  # GET /ads/1/edit
  def edit
  end

  # POST /ads
  # POST /ads.json
  def create
    @ad = Ad.new(ad_params)
    @ad.user_id = 1

    respond_to do |format|
      if @ad.save
        format.html { redirect_to @ad, notice: 'Ad was successfully created.' }
        format.json { render :show, status: :created, location: @ad }
      else
        format.html { render :new }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ads/1
  # PATCH/PUT /ads/1.json
  def update
    respond_to do |format|
      if @ad.update(ad_params)
        format.html { redirect_to @ad, notice: 'Ad was successfully updated.' }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_params
      params.require(:ad).permit(:title, :short_description, :body, :price, :tags)
    end
end
