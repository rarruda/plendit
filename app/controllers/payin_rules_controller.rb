class PayinRulesController < ApplicationController
  before_action :set_ad, only: [:index, :create, :payout_estimate]
  before_filter :authenticate_user!

  # GET /payin_rules
  def index
    render partial: 'ads/secondary_prices'
  end

  # POST /payin_rules
  # POST /payin_rules.json
  def create
    @payin_rule = @ad.payin_rules.build(payin_rule_params)

    if @payin_rule.save
      render text: "Added rule";
    else
      LOG.error "payout rule was not saved:... #{@payin_rule.inspect}"
      render text: "failed", status: :bad_request
    end
  end

  # POST /payin_rules/payout_estimate
  def payout_estimate
    @ad.readonly!
    @payin_rule = @ad.payin_rules.build( payin_rule_params )

    reply = {
      valid:  @payin_rule.valid?,
      markup: render_to_string(partial: 'ad_price_estimate.html'), format: :html
    }.to_json

    respond_to do |format|
      format.json {
        render json: reply
      }
    end
  end

  # DELETE /payin_rules/1
  # DELETE /payin_rules/1.json
  def destroy
    @payin_rule = PayinRule.find_by(guid: params[:guid])

    if @payin_rule.destroy!
      head :ok
    else
      head :bad_request
    end
  end

  private
    def set_ad
      @ad = Ad.find(params[:ad_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payin_rule_params
      params.require(:payin_rule).permit(:id, :guid, :effective_from, :payin_amount, :payin_amount_in_h, :_destroy)
    end
end

