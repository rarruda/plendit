class BookingMailer < ActionMailer::Base
  default from: 'notifications@plendit.com'

  def notify_owner_accepted booking_id
    LOG.info 'foobar'
    @booking = Booking.find( booking_id )

    # Attachments:
    attach_files = []
    attach_files << "Forsikringsbevis_Ting.pdf"                       if @booking.ad.bap?
    attach_files << "Forsikringsvilkaar_Korttidsforsikring_Ting.pdf"  if @booking.ad.bap?
    attach_files << "Forsikringsbevis_Innbo.pdf"                      if @booking.ad.realestate?
    attach_files << "Forsikringsvilkaar_Korttidsforsikring_Innbo.pdf" if @booking.ad.realestate?
    attach_files << "Forsikringsvilkaar_Korttidsforsikring_motorvogn.pdf" if @booking.ad.motor?

    if @booking.ad.motor?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Bil.pdf"     if @booking.ad.car?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Camping.pdf" if @booking.ad.caravan?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Moped_ATV_Snoescooter.pdf"     if @booking.ad.scooter?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Traktor_Gressklipper_Snoe.pdf" if @booking.ad.tractor?
    end

    attach_files.each do |filename|
      attachments[filename] = File.read( "#{Rails.root}/public/docs/if/#{filename}" )
    end

    mail( to: @booking.user.email, subject: "Plendit: du har bekreftet booking" )
  end

  def notify_renter_accepted booking_id
    @booking = Booking.find( booking_id )

    mail( to: @booking.from_user.email, subject: "Plendit: eier har bekreftet booking" )
  end
end
