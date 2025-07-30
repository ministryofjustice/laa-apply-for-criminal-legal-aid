require 'rails_helper'
RSpec.describe 'Language toggle' do
  include_context 'when logged in'

  context 'when welsh translation feature flag is not enabled' do
    before do
      allow(FeatureFlags).to receive(:welsh_translation) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }

      visit root_path
    end

    it 'does not show the language toggle' do
      expect(page).not_to have_css('.language-toggle')
      expect(page).not_to have_link('Cymraeg', href: '/applications?locale=cy')
      expect(page).not_to have_css('.govuk-link--no-underline', text: 'English')
    end
  end

  context 'when welsh translation feature flag is enabled' do
    before do
      allow(FeatureFlags).to receive(:welsh_translation) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      visit root_path
    end

    it 'shows the language toggle' do
      expect(page).to have_css('.language-toggle')
      expect(page).to have_link('Cymraeg', href: '/applications?locale=cy')
      expect(page).to have_css('.govuk-link--no-underline', text: 'English')
    end
  end
end
