class RemoveUnusedFieldsFromUserPaymentCards < ActiveRecord::Migration
  def change
    remove_column :user_payment_cards, :access_key
    remove_column :user_payment_cards, :preregistration_data
    remove_column :user_payment_cards, :registration_data
    remove_column :user_payment_cards, :card_registration_url
  end
end
