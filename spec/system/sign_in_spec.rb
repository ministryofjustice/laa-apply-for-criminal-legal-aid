require 'rails_helper'

RSpec.describe 'Sign in user journey' do
  before do
    visit '/'
    click_on 'Start now'
  end

  context 'user is not signed in' do
    it 'redirects to the login page' do
      expect(current_url).to match('/login')
      expect(page).to have_content('Access restricted')
    end
  end

  context 'user is signed in' do
    before do
      allow_any_instance_of(
        Datastore::ApplicationCounters
      ).to receive_messages(returned_count: 5)

      click_button 'Sign in with LAA Portal'
    end

    it 'authenticates the user and redirect to the dashboard' do
      expect(current_url).to match(crime_applications_path)
    end

    it 'renders the user menu in the header' do
      expect(page).to have_css('nav.govuk-header__navigation')
      expect(page).to have_css('.app-header__auth-user', text: 'test-user')
      expect(page).to have_button('Sign out')
    end

    it 'on sign out it redirects to the home' do
      click_button 'Sign out'

      expect(current_url).to match(root_path)
      expect(page).not_to have_css('nav.govuk-header__navigation')
    end
  end
end
