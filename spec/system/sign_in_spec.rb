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

  context 'user signs in but is not allowed to use the service' do
    before do
      allow(
        OmniAuth.config
      ).to receive(:mock_auth).and_return(
        saml: OmniAuth::AuthHash.new(info: { office_codes: '' })
      )

      click_button 'Sign in with LAA Portal'
    end

    it 'redirects to the home page with a flash alert' do
      expect(current_url).to eq(root_url)
      expect(page).to have_content('Your account cannot use this service as it does not have any office codes.')
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
end
