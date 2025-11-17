require 'rails_helper'

RSpec.describe 'Viewing In Progress Criminal Legal Aid applications' do
  include_context 'when logged in'

  context 'when there are in progress records to return' do
    let(:number_of_records) { 2 }

    before do
      apps = Array.new(number_of_records) do
        { id: SecureRandom.uuid, office_code: '2A555X' }
      end

      peeps = apps.map do |app|
        { crime_application_id: app[:id], first_name: 'J', last_name: app[:id] }
      end

      # rubocop:disable Rails/SkipsModelValidations
      CrimeApplication.insert_all(apps)
      Applicant.insert_all(peeps)
      # rubocop:enable Rails/SkipsModelValidations

      visit 'applications'
    end

    it 'defaults to sort by created at desc' do
      expect(find(:element, 'aria-sort': 'descending')).to have_text 'Start date'
    end

    ['Name', 'Start date', 'LAA reference', 'Application type'].each do |header_text|
      it "sorts by #{header_text} all in progress applications" do
        click_button header_text
        expect(find(:element, 'aria-sort': 'ascending')).to have_text header_text
      end
    end

    it 'preserves the locale when sorting' do
      click_link 'Cymraeg'
      click_button 'Enw'
      expect(find(:element, 'aria-sort': 'ascending')).to have_text 'Enw'
    end

    context 'when there are more than 30 records' do
      let(:number_of_records) { Kaminari.config.default_per_page + 1 }

      it 'can navigate to the next page and maintain sorting' do
        click_button 'Name'
        click_button 'Next'

        expect(find(:element, 'aria-label': 'Page 2', 'aria-current': 'page')).to have_text(2)
        expect(find(:element, 'aria-sort': 'ascending')).to have_text 'Name'
      end
    end
  end

  context 'when there are no records to return' do
    it 'informs the user that there are no applications' do
      expect(page).to have_element('h2', text: 'There are no applications')
    end
  end

  it 'shows "Submitted" as the current page' do
    current_tab = find(:element, 'aria-current': 'page', class: 'moj-sub-navigation__link')

    expect(current_tab).to have_text 'In progress'
  end
end
