class PayinRulesController < ApplicationController
  before_action :set_payin_rule, only: [:destroy]
  before_action :set_ad, only: [:create, :payout_estimate]
  before_filter :authenticate_user!

  # POST /payin_rules
  # POST /payin_rules.json
  def create
    @payin_rule = @ad.payin_rules.build(payin_rule_params)

    if @payin_rule.save
      render text: "Added rule";
    else
      render text: "failed", status: :bad_request
    end
  end

  def payout_estimate
    @ad.readonly!

    #payin_amount = Integer(payin_rule_params[:payin_amount_in_h]) * 100;

    #@rule = @ad.payin_rules.build( unit: 'day', effective_from: payin_rule_params[:effective_from], payin_amount_in_h: payin_rule_params[:payin_amount_in_h] )
    @rule = @ad.payin_rules.build( payin_rule_params )
    respond_to do |format|
      format.json
    end
  end

  # DELETE /payin_rules/1
  # DELETE /payin_rules/1.json
  def destroy
    if @payin_rule.destroy!
      head :ok
    else
      head :bad_request
      #redirect_to edit_users_path(:anchor => 'payin_rules')
    end
  end

  private
    def set_ad
      @ad = Ad.find(params[:ad_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_payin_rule
#      @payin_rule = PayinRule.find(params[:guid])
      @payin_rule = PayinRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payin_rule_params
      params.require(:payin_rule).permit(:id, :guid, :effective_from, :payin_amount, :payin_amount_in_h)
    end
end

