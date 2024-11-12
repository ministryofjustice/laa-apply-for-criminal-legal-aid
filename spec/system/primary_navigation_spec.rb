require 'rails_helper'

RSpec.describe 'Primary navigation' do
  include_context 'when logged in'

  before do
    allow(FeatureFlags).to receive(:search).and_return(
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    )
  end

  it 'takes you to the applications dashboard when you click "Your applications"' do
    click_on('Your applications')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Your applications')
    expect(page).to have_current_path '/applications'
  end

  it 'takes you to search when you click "Search"' do
    click_on('Search')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Search for an application')
    expect(page).to have_current_path '/application_searches/new'
  end

  context 'when drafting application' do
    it 'does not display primary navigation' do
      click_link('Start an application')

      expect(page).not_to have_content('Your applications')
      expect(page).not_to have_content('Search')
    end
  end
end
