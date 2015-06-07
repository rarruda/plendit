class AddPhoneAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_number_confirmation_token, :string
    add_column :users, :phone_number_confirmed_at, :datetime
    add_column :users, :phone_number_confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_phone_number, :string, limit: 8
  end
end
