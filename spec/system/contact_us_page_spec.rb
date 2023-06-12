require 'rails_helper'

RSpec.describe 'Contact us page' do
  before do
    visit about_contact_path
  end

  it 'shows the contact us page with the correct contact details' do
    expect(page).to have_css('h1', text: 'Contact us')

    expect(page).to have_css('p', text: 'Telephone: 0300 200 2020')
    expect(page).to have_css('p', text: 'Email: apply-for-criminal-legal-aid@justice.gov.uk')
  end
end
