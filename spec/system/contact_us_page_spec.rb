require 'rails_helper'

RSpec.describe 'Contact us page' do
  before do
    visit about_contact_path
  end

  it 'shows the contact us page with the correct contact details' do
    expect(page).to have_css('h1', text: 'Contact us')

    expect(page).to have_css('p', text: '0300 200 2020')
  end

  it 'directs non-urgent technical enquiries to the reporting form in a new tab' do
    expect(page).to have_css('h3', text: 'Online')
    expect(page).to have_css('p',
                             text: 'For non-urgent enquiries, submit a technical fault request (opens in a new tab)')
    expect(page).to have_link('submit a technical fault request (opens in a new tab)',
                              href: 'https://laa-technical-fault-reporting-form.form.service.justice.gov.uk/',
                              target: '_blank')
    expect(page.find_link('submit a technical fault request (opens in a new tab)')[:rel]).to include('noopener')
  end

  it 'does not advertise the old support email or email response time' do
    expect(page).not_to have_link(href: 'mailto:online-support@justice.gov.uk')
    expect(page).not_to have_text('We aim to respond within 5 working days.')
  end

  context 'in Welsh' do
    before do
      visit about_contact_path(locale: 'cy')
    end

    it 'shows the supplied Welsh copy and reporting form link' do
      expect(page).to have_css('h3', text: 'Ar-lein')
      expect(page).to have_css('p',
                               text: 'Ar gyfer ymholiadau nad ydynt yn rhai brys, cyflwynwch gais am nam technegol')
      expect(page).to have_link('cyflwynwch gais am nam technegol (yn agor mewn tab newydd)',
                                href: 'https://laa-technical-fault-reporting-form.form.service.justice.gov.uk/',
                                target: '_blank')
    end
  end
end
