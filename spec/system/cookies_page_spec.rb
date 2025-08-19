require 'rails_helper'

RSpec.describe 'Cookies page' do
  before do
    visit cookies_path
  end

  context 'configuring the consent' do
    it 'shows the cookie settings form' do
      expect(page).to have_css('form legend', text: 'Do you want to accept analytics cookies?')

      expect(page).to have_css('form .govuk-radios__label', text: 'Yes')
      expect(page).not_to have_checked_field('cookies-settings-form-consent-accept-field')

      expect(page).to have_css('form .govuk-radios__label', text: 'No')
      expect(page).not_to have_checked_field('cookies-settings-form-consent-reject-field')

      expect(page).to have_button('Save cookie settings')
    end

    it 'accepting analytics cookies' do
      find(:label, for: 'cookies-settings-form-consent-accept-field').click
      click_button 'Save cookie settings'

      expect(current_url).to match(cookies_path)

      expect(page).to have_css('div.govuk-notification-banner--success', text: 'You’ve accepted analytics cookies.')
      expect(page).to have_checked_field('cookies-settings-form-consent-accept-field')
    end

    it 'rejecting analytics cookies' do
      find(:label, for: 'cookies-settings-form-consent-reject-field').click
      click_button 'Save cookie settings'

      expect(current_url).to match(cookies_path)

      expect(page).to have_css('div.govuk-notification-banner--success', text: 'You’ve rejected analytics cookies.')
      expect(page).to have_checked_field('cookies-settings-form-consent-reject-field')
    end
  end

  context 'when the google analytics feature flag is not enabled' do
    before do
      allow(FeatureFlags).to receive(:google_analytics) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }

      visit cookies_path
    end

    it 'does not display the cookie settings form' do
      expect(page).not_to have_css('form legend', text: 'Do you want to accept analytics cookies?')

      expect(page).not_to have_css('form .govuk-radios__label', text: 'Yes')
      expect(page).not_to have_checked_field('cookies-settings-form-consent-accept-field')

      expect(page).not_to have_css('form .govuk-radios__label', text: 'No')
      expect(page).not_to have_checked_field('cookies-settings-form-consent-reject-field')

      expect(page).not_to have_button('Save cookie settings')
    end
  end
end
