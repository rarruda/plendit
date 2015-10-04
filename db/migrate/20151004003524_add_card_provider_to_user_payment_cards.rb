class AddCardProviderToUserPaymentCards < ActiveRecord::Migration
  def change
    add_column :user_payment_cards, :card_provider, :string
    add_column :user_payment_cards, :country, :string, limit: 3
    rename_column :user_payment_cards, :validity_mp, :validity
    rename_column :user_payment_cards, :active_mp, :active
    remove_column :user_payment_cards, :last_known_status_mp, :string
  end
end
