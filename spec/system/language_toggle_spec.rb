require 'rails_helper'

RSpec.describe 'Language toggle' do
  include_context 'when logged in'

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

