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
  
  it 'shows the language toggle links' do
    visit root_path
    toggle_text = page.find('.language-toggle').text
    expect(toggle_text).to eq 'English | Cymraeg'
  end

  context 'when selecting English from Welsh' do
    before do
      visit root_path(locale: 'cy')
    end

    it 'changes the content to English' do
      within('.language-toggle') do
        click_link 'English'
      end
      expect(page).to have_text('Your applications')
      expect(page).not_to have_text('Eich ceisiadau')
    end

    it 'changes link from English to Welsh' do
      within('.language-toggle') do
        click_link 'English'
      end
      expect(page).to have_link('Cymraeg')
      expect(page).not_to have_link('English')
    end
  end

  context 'when selecting Welsh from English' do
    before do
      visit root_path(locale: 'en')
    end

    it 'changes the content to Welsh' do
      within('.language-toggle') do
        click_link 'Cymraeg'
      end
      expect(page).not_to have_text('Your applications')
      expect(page).to have_text('Eich ceisiadau')
    end

    it 'changes link from Welsh to English' do
      within('.language-toggle') do
        click_link 'Cymraeg'
      end
      expect(page).not_to have_link('Cymraeg')
      expect(page).to have_link('English')
    end
  end
end
