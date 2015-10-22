class AddFavoriteToUserPaymentCard < ActiveRecord::Migration
  def change
    add_column :user_payment_cards, :favorite, :boolean, default: false
  end
end
