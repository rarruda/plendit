class AddDefaultValueForActiveToUserPaymentCard < ActiveRecord::Migration
  def change
    change_column_default :user_payment_cards, :active_mp, true
    change_column_null    :user_payment_cards, :active_mp, false
  end
end
