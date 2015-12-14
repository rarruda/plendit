json.extract! @ad, :id, :user_id, :title, :body, :location_id, :status, :category
json.valid @ad.valid?
json.errors @ad.errors
json.errorMarkup @error_markup
json.main_payin_rule do
  json.total_fee format_monetary_full_pretty(@ad.booking_calculator.total_fee(@ad.main_payin_rule))
  json.max_insurance_coverage format_monetary_full_pretty(@ad.booking_calculator.max_insurance_coverage(@ad.main_payin_rule))
  json.payout_amount format_monetary_full_pretty(@ad.booking_calculator.payout_amount(@ad.main_payin_rule))
  json.payin_amount format_monetary_full_pretty(@ad.booking_calculator.payin_amount(@ad.main_payin_rule))
end
json.payin_rules do
  json.array! @ad.payin_rules.each do |payin_rule|
    json.total_fee @ad.booking_calculator.total_fee(payin_rule)
    json.max_insurance_coverage @ad.booking_calculator.max_insurance_coverage(@ad.main_payin_rule)
    json.payout_amount @ad.booking_calculator.payout_amount(payin_rule)
    json.payin_amount @ad.booking_calculator.payin_amount(payin_rule)
  end
end