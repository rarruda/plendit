class ChangeTypeOfValidityToEnumInUserPaymentCard < ActiveRecord::Migration
  def up
    execute "UPDATE user_payment_cards SET validity=1  WHERE validity='UNKNOWN'"
    execute "UPDATE user_payment_cards SET validity=5  WHERE validity='VALID'"
    execute "UPDATE user_payment_cards SET validity=10 WHERE validity='INVALID'"
    change_column :user_payment_cards, :validity, 'integer USING CAST(validity AS integer)'
  end
  def down
    change_column :user_payment_cards, :validity, :string
  end
end
