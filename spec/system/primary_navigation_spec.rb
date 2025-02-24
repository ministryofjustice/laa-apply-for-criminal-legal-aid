require 'rails_helper'

RSpec.describe 'Primary navigation' do
  include_context 'when logged in'

  it 'takes you to the applications dashboard when you click "Your applications"' do
    click_on('Your applications')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Your applications')
    expect(page).to have_current_path '/applications'
  end

  it 'takes you to search when you click "Search"' do
    click_on('Search')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Search submitted applications')
    expect(page).to have_current_path '/application-searches/new'
  end

  context 'when drafting application' do
    it 'does not display primary navigation' do
      click_link('Start an application')

      expect(page).not_to have_content('Your applications')
      expect(page).not_to have_content('Search')
    end
  end

  context 'when on "Your applications"' do
    before { click_link('Your applications') }

    it '`Your applications` is the current tab' do
      expect(search_tab_current?).to be false
      expect(your_applications_tab_current?).to be true
    end
  end

  context 'when on the Submitted applications page' do
    include_context 'with stubbed search results'

    before do
      click_link('Submitted')
    end

    it '`Your applications` is the current tab' do
      expect(search_tab_current?).to be false
      expect(your_applications_tab_current?).to be true
    end
  end

  context 'when on the Returned applications page' do
    include_context 'with stubbed search results'

    before do
      click_link('Returned')
    end

    it '`Your applications` is the current tab' do
      expect(search_tab_current?).to be false
      expect(your_applications_tab_current?).to be true
    end
  end

  context 'when on the new search page' do
    before { click_link('Search') }

    it 'the search tab is the current tab' do
      expect(search_tab_current?).to be true
    end
  end

  context 'when on the search results page' do
    before do
      stub_request(:post, 'http://datastore-webmock/api/v1/searches')
        .to_return(body: { pagination: {}, records: [] }.to_json)

      click_link('Search')
      click_button('Search')
    end

    it 'the search tab is the current tab' do
      expect(search_tab_current?).to be true
    end
  end

  def search_tab_current?
    page.find('a.moj-primary-navigation__link', text: 'Search')['aria-current'] == 'page'
  end

  def your_applications_tab_current?
    page.find('a.moj-primary-navigation__link', text: 'Your applications')['aria-current'] == 'page'
  end
end
