class FeedbackBelongsToBooking < ActiveRecord::Migration
  def change
    add_reference :feedbacks, :booking, index: true, foreign_key: true
    remove_reference :feedbacks, :ad

    # randomly assign the existing feedbacks to bookings.
    # if we had a working production, this would be awful,
    #  but as we dont have a working production yet, that's quite ok.
    execute "UPDATE feedbacks
      SET booking_id = b.id, from_user_id = b.from_user_id
        FROM (
            SELECT id,from_user_id FROM bookings ORDER BY RANDOM() LIMIT 1
        ) AS b"
  end
end
