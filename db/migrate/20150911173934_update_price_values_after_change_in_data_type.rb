class UpdatePriceValuesAfterChangeInDataType < ActiveRecord::Migration
  def up
    execute "UPDATE ads           SET price  = price*100"
    execute "UPDATE bookings      SET amount = amount*100"
    execute "UPDATE booking_items SET amount = amount*100"
  end
  def down
    execute "UPDATE ads           SET price  = price/100"
    execute "UPDATE bookings      SET amount = amount/100"
    execute "UPDATE booking_items SET amount = amount/100"
  end
end
