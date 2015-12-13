class ApplicationMailer < ActionMailer::Base
  default from: "noreply@plendit.com"
  layout 'mailer'

  before_action :add_logo_attachment


  def ad_is_published ad
    @ad = ad

    mail(
      to: @ad.user.email,
      subject: "Plendit: (#{@ad.title}) er nå godkjent og publisert"
    )
  end

  def ad_is_rejected ad
    @ad = ad

    mail(
      to: @ad.user.email,
      subject: "Plendit: (#{@ad.title}) ble ikke godkjent"
    )
  end

  def booking_confirmed booking
    @booking = booking

    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Din forespørsel ble akseptert",
      template_name: 'booking_confirmed__to_renter'
    )


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

    mail(
      to: @booking.user.email,
      subject: "Plendit: Du har godkjent leieforespørselen av (#{@ad.title})",
      template_name: 'booking_confirmed__to_owner'
    )
  end

  def booking_cancelled booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Du har godkjent leieforespørselen av (#{@ad.title})",
      template_name: 'booking_accepted__to_owner'
    )

    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Leieforespørselen av (#{@ad.title}) ble godkjent",
      template_name: 'booking_accepted__to_renter'
    )
  end

  def booking_created booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Noen ønsker å leie (#{@ad.title})",
      template_name: 'booking_created__to_owner'
     )
  end

  def booking_declined booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Din forespørsel ble avslått",
      template_name: 'booking_declined__to_renter'
     )
  end

  # not hooked. needs a scheduled job to trigger it.
  def booking_ends_at_soon booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Leieforeholdet med (#{@ad.title}) starter snart",
      template_name: 'booking_ends_at_soon__to_owner'
    )

    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Leieforeholdet med (#{@ad.title}) slutter snart",
      template_name: 'booking_ends_at_soon__to_renter'
    )
  end

  # not hooked. needs a scheduled job to trigger it.
  def booking_starts_at_soon booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Leieforholdet med (#{@ad.title}) slutter snart",
      template_name: 'booking_starts_at_soon__to_owner'
    )

    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Leieforholdet med (#{@ad.title}) starter snart",
      template_name: 'booking_starts_at_soon__to_renter'
    )
  end

  def user_id_license_approved user, user_document_category
    @user = user

    # template is missing polish
    mail(
      to: @user.email,
      subject: "Plendit: Ditt førerkort ble godkjent"
    )
  end

  # not hooked.
  def user_id_license_expires_soon user, user_document_category
    @user = user

    # template is missing polish
    mail(
      to: @user.email,
      subject: "Plendit: Ditt førerkort er snart ugyldig"
    )
  end

  def user_id_license_not_approved user, user_document_category
    @user = user

    # template is missing polish
    mail(
      to: @user.email,
      subject: "Plendit: Dit Id-kort ble ikke godkjent"
    )
  end

  private
  def add_logo_attachment
    attachments.inline['logo.png'] = File.read('public/images/plendit_mail_logo.png')
  end
end
