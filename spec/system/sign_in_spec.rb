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

  let(:start_button) { find('button.govuk-button--start') }
  let(:start_button_form_action) { start_button.ancestor('form')['action'] }
  let(:disable_entra_logout_feature) { false }

  include_context 'with mock provider data'

  before do
    if disable_entra_logout_feature
      allow(FeatureFlags).to receive(:entra_logout) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    allow_any_instance_of(
      Datastore::ApplicationCounters
    ).to receive_messages(returned_count: 5)

    visit root_path
  end

  context 'user is not signed in' do
    it 'has a start button with action saml authorize' do
      expect(start_button_form_action).to eq(provider_entra_omniauth_authorize_path)
    end

    it 'redirects to the unauthenticated page if trying to access protected routes' do
      visit crime_applications_path

      expect(current_url).to match(unauthenticated_errors_path)
      expect(page).to have_content('Sign in to continue')
    end
  end

  context 'user is signed in, has multiple office codes, but none selected' do
    before do
      start_button.click
      visit root_path
    end

    it 'redirects to the select office path' do
      expect(current_url).to match(steps_provider_select_office_path)
    end

    context 'when the user attempts to access the dashboard' do
      it 'redirects to the select office path' do
        visit 'applications'
        expect(current_url).to match(steps_provider_select_office_path)
        expect(page).not_to have_link('Your applications')
      end
    end
  end

  context 'user signs in but is not yet enrolled' do
    before do
      allow(
        OmniAuth.config
      ).to receive(:mock_auth).and_return(
        entra: OmniAuth::AuthHash.new(info: { office_codes: [] })
      )

      start_button.click
    end

    it 'redirects to the error page' do
      expect(current_url).to match(not_enrolled_errors_path)
      expect(page).to have_content('You’re not enrolled in the apply for criminal legal aid service')
    end
  end

  context 'user is signed in, has multiple accounts' do
    before do
      allow_any_instance_of(Provider).to receive_messages(
        selected_office_code: '1A123B'
      )

      start_button.click
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
      expect(page).to have_link('Sign out')
    end

    it 'on sign out it redirects to the home' do
      expect(page).to have_link('Sign out', href: '/providers/auth/entra/logout?locale=en')

      visit 'providers/logout'

      expect(current_url).to match(root_path)
      expect(page).to have_content('You have signed out')
      expect(page).not_to have_css('nav.govuk-header__navigation')
    end

    context 'when entra logout diabled' do
      let(:disable_entra_logout_feature) { true }

      it 'on sign out it redirects to the home' do
        click_link('Sign out')
        expect(current_url).to match(root_path)
        expect(page).to have_content('You have signed out')
        expect(page).not_to have_css('nav.govuk-header__navigation')
      end
    end
  end

  context 'user is signed in, has multiple office codes, with an active office selected' do
    before do
      start_button.click
      visit root_path
      choose('1A123B')
      click_button('Save and continue')
    end

    context 'when the user attempts to access the dashboard' do
      it 'shows the dashboard' do
        visit 'applications'
        expect(current_url).to match(crime_applications_path)
        expect(page).to have_link('Your applications')
      end
    end

    context 'when the user attempts to access the dashboard after the selected office code is deactivated' do
      it 'redirects to the select the office page' do
        mock_pda('1A123B', status: 204)
        visit 'applications'
        expect(current_url).to match(steps_provider_select_office_path)
      end
    end
  end

  context 'user is signed in, only has one account' do
    before do
      allow_any_instance_of(
        Provider
      ).to receive(:office_codes).and_return(['A1'])

      start_button.click
    end

    it 'authenticates the user and redirects to the dashboard' do
      expect(current_url).to match(crime_applications_path)
    end
  end

  context 'user is signed out if session inactivity is exceeded' do
    before do
      allow_any_instance_of(Provider).to receive(:office_codes).and_return(['A1'])
      allow(Provider).to receive(:timeout_in).and_return(5.minutes)

      start_button.click
    end

    it 'signs out the user after `timeout_in` time has passed' do
      travel 6.minutes

      click_link 'Your applications'

      expect(current_url).to match(invalid_session_errors_path)
      expect(page).to have_content('For your security, we signed you out')
    end
  end

  context 'user is signed out if session lifespan is exceeded' do
    before do
      allow_any_instance_of(Provider).to receive(:office_codes).and_return(['A1'])
      allow(Provider).to receive(:reauthenticate_in).and_return(5.minutes)

      start_button.click
    end

    it 'signs out the user after `reauthenticate_in` time has passed' do
      travel 6.minutes

      click_link 'Your applications'

      expect(current_url).to match(reauthenticate_errors_path)
      expect(page).to have_content('For your security, we signed you out')
    end
  end

  context 'when the user account is locked' do
    before do
      allow_any_instance_of(Provider).to receive(:locked_at).and_return(1.day.ago)
      start_button.click
    end

    it 'forbids the user from accessing the service' do
      expect(current_url).to match(account_locked_errors_path)
      expect(page).to have_content('You cannot access this service')
    end
  end

  context 'when the sign in fails' do
    before do
      OmniAuth.config.mock_auth[:entra] = :access_denied
    end

    after do
      OmniAuth.config.mock_auth[:entra] = Silas::OidcStrategy.mock_auth
    end

    it 're-raises the exception for handling by the `ApplicationController`' do
      expect { start_button.click }.to raise_error(StandardError)
    end
  end
end
