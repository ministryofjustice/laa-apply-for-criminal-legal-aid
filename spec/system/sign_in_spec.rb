require 'rails_helper'

RSpec.describe 'Sign in user journey' do
  # Do not leave left overs, as this test will persist
  # a mock provider to the database
  before(:all) do
    Provider.destroy_all
  end

  after(:all) do
    Provider.destroy_all
  end

  before do
    allow_any_instance_of(
      Datastore::ApplicationCounters
    ).to receive_messages(returned_count: 5)

    visit '/'
    click_on 'Start now'
  end

  context 'user is not signed in' do
    it 'redirects to the login page' do
      expect(current_url).to match('/login')
      expect(page).to have_content('Access restricted')
    end
  end

  context 'user signs in but is not yet enrolled' do
    before do
      allow(
        OmniAuth.config
      ).to receive(:mock_auth).and_return(
        saml: OmniAuth::AuthHash.new(info: { office_codes: ['1X000X'] })
      )

      click_button 'Sign in with LAA Portal'
    end

    it 'redirects to the error page' do
      expect(current_url).to match(not_enrolled_errors_path)
      expect(page).to have_content('You need to apply using eForms')
    end
  end

  context 'user is signed in, has multiple accounts' do
    before do
      allow_any_instance_of(
        Provider
      ).to receive(:selected_office_code).and_return('1A123B')

      click_button 'Sign in with LAA Portal'
    end

    it 'authenticates the user and redirects to the office account confirmation page' do
      expect(current_url).to match(edit_steps_provider_confirm_office_path)
      expect(page).to have_content('Is 1A123B your office account number?')

      choose('No, another office is handling this application')
      click_button 'Save and continue'

      expect(current_url).to match(edit_steps_provider_select_office_path)

      expect(page).to have_css('.govuk-radios__label', text: '1A123B')
      expect(page).to have_css('.govuk-radios__label', text: '2A555X')

      choose('2A555X')
      click_button 'Save and continue'
      expect(current_url).to match(crime_applications_path)
    end

    it 'renders the user menu in the header' do
      expect(page).to have_css('nav.govuk-header__navigation')
      expect(page).to have_css('.app-header__auth-user', text: 'provider@example.com')
      expect(page).to have_button('Sign out')
    end

    it 'on sign out it redirects to the home' do
      click_button 'Sign out'

      expect(current_url).to match(root_path)
      expect(page).not_to have_css('nav.govuk-header__navigation')
    end
  end

  context 'user is signed in, only has one account' do
    before do
      allow_any_instance_of(
        Provider
      ).to receive(:office_codes).and_return(['A1'])

      click_button 'Sign in with LAA Portal'
    end

    it 'authenticates the user and redirects to the dashboard' do
      expect(current_url).to match(crime_applications_path)
    end
  end

  context 'user is signed out if session lifespan is exceeded' do
    before do
      allow_any_instance_of(Provider).to receive(:office_codes).and_return(['A1'])
      allow(Provider).to receive(:reauthenticate_in).and_return(5.minutes)

      click_button 'Sign in with LAA Portal'
    end

    it 'signs out the user after `reauthenticate_in` time has passed' do
      travel 6.minutes

      click_link 'Your applications'

      expect(current_url).to match('/login')
      expect(page).to have_content('Your Portal session expired. Please sign in again to continue.')
    end
  end
end
