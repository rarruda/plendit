require 'rails_helper'

describe 'searching and looking at an ad' do
  #fixtures :all
  #fixtures :ads

  it 'can search for an ad in the frontpage' do
    @ads = FactoryGirl.build_stubbed(:ad_bap,
      title:"Nikon d810", body: "en fin nikon FX kamera",
      payin_rules: [ FactoryGirl.build_stubbed(:payin_rule) ]
    )

    visit root_path
    fill_in 'q', with: 'Nikon'
    click_on 'Søk'

    screenshot_and_save_page
    #expect(current_path).to eq(search_path(q: 'Nikon'))
    expect(current_path).to eq(search_path)

    #expect(page).to have_content("Nikon")
    #within('div[class=search-result-item__text-container]') do
    #  expect(page).to have_link_a?
    #  expect(page).to have_content? (ads.title)
    #end
  end

end