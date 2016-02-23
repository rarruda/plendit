class ApplicationMailer < ActionMailer::Base
  helper :application

  default from: 'noreply@plendit.com'
  layout 'mailer'

  before_action :add_logo_attachment


  def booking_confirmed__to_renter booking
    @booking = booking
    add_insurance_documents
    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Din forespørsel ble akseptert",
      template_name: 'booking_confirmed__to_renter'
    )
  end

  def booking_confirmed__to_owner booking
    @booking = booking
    add_insurance_documents
    mail(
      to: @booking.user.email,
      subject: "Plendit: Du har godkjent leieforespørselen av (#{@booking.ad.title})"
    )
  end

  def booking_cancelled__to_owner booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Forespørsel ble kansellert"
    )
  end

  def booking_cancelled__to_renter booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Din forespørsel ble kansellert"
    )
  end

  def booking_created__to_owner booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Noen ønsker å leie (#{@booking.ad.title})"
    )
  end

  def booking_declined__to_renter booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Din forespørsel ble avslått"
    )
  end

  def deposit_withdrawals__to_owner booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: melding om betaling"
    )
  end

  # not hooked up. needs a scheduled job to trigger it.
  def booking_ends_at_soon__to_owner booking
    @booking = booking

    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Leieforeholdet (#{@booking.ad.title}) slutter snart"
    )
  end

  # not hooked up. needs a scheduled job to trigger it.
  def booking_ends_at_soon__to_renter booking
    @booking = booking

    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Leieforeholdet med (#{@booking.ad.title}) slutter snart"
    )
  end

  # not hooked up. needs a scheduled job to trigger it.
  def booking_starts_at_soon__to_owner booking
    @booking = booking

    mail(
      to: @booking.user.email,
      subject: "Plendit: Leieforholdet med (#{@booking.ad.title}) slutter snart"
    )
  end

  # not hooked up. needs a scheduled job to trigger it.
  def booking_starts_at_soon__to_renter booking
    @booking = booking

    mail(
      to: @booking.from_user.email,
      subject: "Plendit: Leieforholdet med (#{@booking.ad.title}) starter snart"
    )
  end

  # not hooked up.
  def user_id_license_approved user, user_document_category
    @user = user

    # template is missing polish
    mail(
      to: @user.email,
      subject: "Plendit: Ditt førerkort ble godkjent"
    )
  end

  # not hooked up.
  def user_id_license_expires_soon user, user_document_category
    @user = user

    # template is missing polish
    mail(
      to: @user.email,
      subject: "Plendit: Ditt førerkort er snart ugyldig"
    )
  end

  # not hooked up.
  def user_id_license_not_approved user, user_document_category
    @user = user

    # template is missing polish
    mail(
      to: @user.email,
      subject: "Plendit: Dit Id-kort ble ikke godkjent"
    )
  end


  def message__to_user message
    @message = message

    mail(
      to: @message.to_user.email,
      subject: "Plendit: melding om utleie av \"#{@message.booking.ad.title}\""
    )
  end

  def accident_report_created__to_customer_service accident_report
    @accident_report = accident_report

    # template is missing polish
    mail(
      to: Plendit::Application.config.x.customerservice.email,
      subject: "Plendit: accident_report created"
    )
  end

  private

  def add_insurance_documents
    # Attachments:
    attach_files = []
    attach_files << "Forsikringsbevis_Ting.pdf"                       if @booking.ad.bap?
    attach_files << "Forsikringsvilkaar_Korttidsforsikring_Ting.pdf"  if @booking.ad.bap?
    attach_files << "Forsikringsbevis_Innbo.pdf"                      if @booking.ad.realestate?
    attach_files << "Forsikringsvilkaar_Korttidsforsikring_Innbo.pdf" if @booking.ad.realestate?
    attach_files << "Forsikringsbevis_Baat.pdf"                       if @booking.ad.boat?
    attach_files << "Forsikringsvilkaar_Korttidsforsikring_Baat.pdf"  if @booking.ad.boat?
    attach_files << "Sammendrag_av_Korttidsforsikring_Baat.pdf"       if @booking.ad.boat?

    if @booking.ad.motor?
      if @booking.ad.vintage_car?
        attach_files << "Forsikringsbevis_motorvogn_Veteranbil.pdf"
      else
        attach_files << "Forsikringsbevis_motorvogn.pdf"
      end
      attach_files << "Forsikringsvilkaar_Korttidsforsikring_motorvogn.pdf"

      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Bil.pdf"     if @booking.ad.car?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Camping.pdf" if @booking.ad.caravan?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Veteranbil.pdf"                if @booking.ad.vintage_car?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Moped_ATV_Snoescooter.pdf"     if @booking.ad.scooter?
      attach_files << "Sammendrag_av_Korttidsforsikring_motorvogn_Traktor_Gressklipper_Snoe.pdf" if @booking.ad.tractor?
    end

    attach_files.each do |filename|
      attachments[filename] = File.read( "#{Rails.root}/public/docs/if/#{filename}" )
    end
  end

  def add_logo_attachment
    attachments.inline['logo.png'] = File.read('public/images/plendit_mail_logo.png')
  end
end
