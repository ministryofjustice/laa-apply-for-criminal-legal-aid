require 'rails_helper'

RSpec.describe 'Cookie consent banner' do
  before do
    visit root_path
  end

  context 'when the consent is not set yet' do
    it 'shows the consent banner' do
      expect(page).to have_css('.govuk-cookie-banner', text: 'Cookies on Apply for criminal legal aid')
      expect(page).to have_button('Accept analytics cookies')
      expect(page).to have_button('Reject analytics cookies')
      expect(page).to have_link('View cookies', href: cookies_path)
    end

    it 'does not show the consent banner in the cookies page' do
      visit cookies_path
      expect(page).not_to have_css('.govuk-cookie-banner')
    end

    it 'can accept cookies' do
      click_button 'Accept analytics cookies'
      expect(current_url).to match(root_path)

      expect(page).not_to have_css('.govuk-cookie-banner', text: 'Cookies on Apply for criminal legal aid')
      expect(page).to have_css('.govuk-cookie-banner p.govuk-body', text: 'You’ve accepted analytics cookies.')
      expect(page).to have_css('.govuk-button-group a.govuk-button', text: 'Hide cookie message')
    end

    it 'can reject cookies' do
      click_button 'Reject analytics cookies'
      expect(current_url).to match(root_path)

      expect(page).not_to have_css('.govuk-cookie-banner', text: 'Cookies on Apply for criminal legal aid')
      expect(page).to have_css('.govuk-cookie-banner p.govuk-body', text: 'You’ve rejected analytics cookies.')
      expect(page).to have_css('.govuk-button-group a.govuk-button', text: 'Hide cookie message')
    end

    it 'redirects to the page where the banner was accepted or rejected' do
      visit about_contact_path
      expect(page).to have_css('.govuk-cookie-banner')
      click_button 'Accept analytics cookies'
      expect(current_url).to match(about_contact_path)
    end

    it 'can hide cookies message' do
      click_button 'Accept analytics cookies'
      click_link 'Hide cookie message'
      expect(page).not_to have_css('.govuk-cookie-banner')
    end
  end

  context 'when the consent is already set' do
    before do
      click_button 'Accept analytics cookies'
    end

    it 'do not show the consent banner' do
      visit root_path
      expect(page).not_to have_css('.govuk-cookie-banner')
    end
  end

  context 'when google analytics feature flag is not enabled' do
    before do
      allow(FeatureFlags).to receive(:google_analytics) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }

      visit root_path
    end

    it 'does not show the consent banner' do
      expect(page).not_to have_css('.govuk-cookie-banner', text: 'Cookies on Apply for criminal legal aid')
      expect(page).not_to have_button('Accept analytics cookies')
      expect(page).not_to have_button('Reject analytics cookies')
      expect(page).not_to have_link('View cookies', href: cookies_path)
    end
  end
end
