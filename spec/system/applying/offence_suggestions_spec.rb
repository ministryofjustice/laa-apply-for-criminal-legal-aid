require 'rails_helper'

RSpec.describe 'Selecting an offence suggestion', :js do
  include_context 'when logged in'

  let(:crime_application) { create_test_application(office_code:) }
  let(:charge) { crime_application.create_case!.charges.create! }
  let(:offence_name) { 'Theft from a shop (Over £100,000)' }

  before do
    crime_application.create_applicant!(first_name: 'Jo', last_name: 'Bloggs')
    visit edit_steps_case_charges_path(crime_application, charge_id: charge)
  end

  it 'shows matching suggestions and saves the selected offence' do
    fill_in 'Offence', with: 'Theft from a shop'

    # This list is created by JavaScript; the native datalist is not sufficient.
    within('ul[role="listbox"]') do
      find('li[role="option"]', text: offence_name).click
    end

    expect(page).to have_field('Offence', with: offence_name)
    expect(page).to have_no_css('ul[role="listbox"]')

    save_and_continue

    expect(page).to have_current_path(edit_steps_case_charges_dates_path(crime_application, charge_id: charge))
    expect(charge.reload.offence_name).to eq(offence_name)
  end
end
