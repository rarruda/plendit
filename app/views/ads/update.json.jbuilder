json.extract! @ad, :id, :user_id, :title, :body, :location_id, :status, :category
json.valid @ad.valid?
json.errors @ad.errors
json.errorMarkup @error_markup
json.main_payin_rule_markup @main_payin_rule_markup
