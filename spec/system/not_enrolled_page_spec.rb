require 'rails_helper'

RSpec.describe 'Not enrolled page' do
  it 'directs non-urgent enquiries to the reporting form instead of email' do
    visit not_enrolled_errors_path

    expect(page).to have_css('h2', text: 'Online')
    expect(page).to have_css('p',
                             text: 'For non-urgent enquiries, submit a technical fault request (opens in a new tab)')
    expect(page).to have_link('submit a technical fault request (opens in a new tab)', exact: true,
                              href: 'https://laa-technical-fault-reporting-form.form.service.justice.gov.uk/',
                              target: '_blank')
    expect(page.find_link('submit a technical fault request (opens in a new tab)')[:rel]).to include('noopener')
    expect(page).not_to have_link(href: 'mailto:online-support@justice.gov.uk')
    expect(page).not_to have_text('We aim to respond within 5 working days.')
  end

  it 'uses the existing approved Welsh copy' do
    visit not_enrolled_errors_path(locale: 'cy')

    expect(page).to have_css('h2', text: 'Ar-lein')
    expect(page).to have_css('p',
                             text: 'Ar gyfer ymholiadau nad ydynt yn rhai brys, cyflwynwch gais am nam technegol')
    expect(page).to have_link('cyflwynwch gais am nam technegol (yn agor mewn tab newydd)', exact: true,
                              href: 'https://laa-technical-fault-reporting-form.form.service.justice.gov.uk/',
                              target: '_blank')
    expect(page).not_to have_link(href: 'mailto:online-support@justice.gov.uk')
    expect(page).not_to have_text('Ein nod yw ymateb o fewn 5 diwrnod gwaith.')
  end
end
