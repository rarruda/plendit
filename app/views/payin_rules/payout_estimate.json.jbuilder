json.total_fee              format_monetary_full_pretty( @ad.booking_calculator.total_fee(@payin_rule) )
json.max_insurance_coverage format_monetary_full_pretty( @ad.booking_calculator.max_insurance_coverage(@ad.main_payin_rule) )
json.payout_amount          format_monetary_full_pretty( @ad.booking_calculator.payout_amount(@payin_rule) )
json.payin_amount           format_monetary_full_pretty( @ad.booking_calculator.payin_amount(@payin_rule) )