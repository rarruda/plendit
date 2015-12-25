class ChangeStatusCodesInBooking < ActiveRecord::Migration
  def up
    execute "UPDATE bookings SET status = 40 WHERE status = 15;"
    execute "UPDATE bookings SET status = 9  WHERE status = 5;"
    execute "UPDATE bookings SET status = 8  WHERE status = 4;"
    execute "UPDATE bookings SET status = 6  WHERE status = 3;"
    execute "UPDATE bookings SET status = 4  WHERE status = 2;"
    execute "UPDATE bookings SET status = 2  WHERE status = 1;"
  end
  def down
    execute "UPDATE bookings SET status = 0  WHERE status = 1;" # payment_preauthorized => created
    execute "UPDATE bookings SET status = 1  WHERE status = 2;"
    execute "UPDATE bookings SET status = 2  WHERE status = 3;" # payment_confirmed => started
    execute "UPDATE bookings SET status = 2  WHERE status = 4;"
    execute "UPDATE bookings SET status = 3  WHERE status = 6;"
    execute "UPDATE bookings SET status = 4  WHERE status = 8;"
    execute "UPDATE bookings SET status = 5  WHERE status = 9;"
    execute "UPDATE bookings SET status = 10 WHERE status = 13;" # payment_preauthorization_failed => aborted
    execute "UPDATE bookings SET status = 15 WHERE status = 40;"
  end
end
