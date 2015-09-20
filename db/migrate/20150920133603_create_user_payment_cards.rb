class CreateUserPaymentCards < ActiveRecord::Migration
  def change
    create_table :user_payment_cards do |t|
      t.string :guid, limit: 36
      t.references :user, index: true, foreign_key: true
      t.string :card_vid
      t.string :currency, limit: 3
      t.string :card_type
      t.string :access_key
      t.string :preregistration_data
      t.string :registration_data
      t.string :card_registration_url
      t.string :number_alias, limit: 16
      t.string :expiration_date, limit: 4
      t.string :last_known_status_mp
      t.string :validity_mp
      t.boolean :active_mp

      t.timestamps null: false
    end
    add_index :user_payment_cards, :guid
    add_index :user_payment_cards, :card_vid
  end
end
