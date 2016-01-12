require 'rails_helper'


describe 'searching and looking at an ad' do
  #fixtures :all
  #fixtures :ads

  before :all do
    # FIXME: Build a user, set phone_number to 99999999 and then sign in with that user. Now we've just done it directly in the DB.
    email = "test2@example.com"
    password = "foobar1234"
    #user = FactoryGirl.create(:user,
    #  id: 755,
    #  email: "test2@example.com",
    #  password: password,
    #  phone_number: '99994444',
    #  phone_number_confirmed_at: 1.day.ago,
    #  payin_wallet_vid: 10398444,
    #  payout_wallet_vid: 10398445,
    #  payment_provider_vid: 10398443,
    #  confirmed_at: 1.day.ago,
    #  nationality: 'NO',
    #  country_of_residence: 'NO',
    #  status: :verified,
    #  verification_level: :internally_verified,
    #)
    sign_in_with(email, password)
  end


  it 'can search for an ad in the frontpage', js: true do
    # @ads = FactoryGirl.build_stubbed(:ad_bap,
    #   title:"Nikon D810", body: "en fin nikon FX kamera",
    #   payin_rules: [ FactoryGirl.build_stubbed(:payin_rule) ]
    # )

    # Log in automatically:
    # username, password = ENV['PCONF_HTTP_AUTH_CRED_LIST'].split(',').first.split(':')
    # page.driver.basic_authorize(username, password)
    # visit root_path
    #page.visit("http://#{username}:#{password}@#{page.driver.rack_server.host}:#{page.driver.rack_server.port}/#{root_path}")
    #basic_auth(username, password)

    #basic = ActionController::HttpAuthentication::Basic
    #credentials = basic.encode_credentials('finn', 'takhoyde')


    visit root_path
    fill_in 'q', with: 'Sykkel'
    click_on 'Søk'

    #expect(current_path).to eq(search_path(q: 'Nikon'))
    expect(current_path).to eq(search_path)

    expect(page).to have_content("EcoRide Flexible sammenleggbar EL-sykkel")
    #within(' div[class=search-result-link__text-container]') do
    within(:xpath, "//div[@data-adid='11']") do
      expect(page).to have_content("EcoRide Flexible sammenleggbar EL-sykkel")
      click_link("EcoRide Flexible sammenleggbar EL-sykkel")
    end

    click_on 'Gå til booking'

    start_date = 1.day.from_now.strftime('%Y-%m-%d')
    end_date   = 3.days.from_now.strftime('%Y-%m-%d')
    #click_on :xpath, "span[data-date=#{start_date}]"
    page.find('.k-calendar')
    find("#booking_starts_at_date").set start_date
    find("#booking_ends_at_date").set end_date
    #should test clicking on the calender too, but we are lazy..k-active

    click_on 'Send forespørsel'

    guid = URI.parse(current_url).path.split('/').last
    puts guid

    expect(page).to have_content("Venter på svar")

    sleep 15

    b = Booking.find_by(guid: guid)
    if b.payment_preauthorized?
      b.confirm!
      puts "confirm! booking_status:#{b.status}"

      sleep 40
      if b.payment_confirmed?
        puts "profit!"
      else
        puts "sad. booking_status:#{b.status}"
      end
    else
      puts "payment not preauthorized booking_status: #{b.status}"
    end

  end

end