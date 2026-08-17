require 'rails_helper'

RSpec.describe 'Viewing dashboard with Contingent Liability Criminal Legal Aid applications' do
  include_context 'when logged in'
  include_context 'with stubbed search results'

  before do
    click_link('Start an application')
    choose('New application')
    save_and_continue

    # edit (Task list)
    click_link('Client details')

    # steps/client/details
    fill_in('First name', with: 'Jo')
    fill_in('Last name', with: 'Bloggs')
    fill_date(
      'What is their date of birth?',
      with: Passporting::AGE_PASSPORTED_UNTIL.ago.to_date.next_day
    )
    save_and_continue
  end

  context 'when an office transitions to Contingent Liability' do
    before do
      mock_pda('2A555X', fixture: 'contingent_liability')

      visit('/')
    end

    it 'shows error message when trying to start a new application' do
      click_on('Start an application')

      within('.govuk-error-summary') do |error|
        expect(error).to have_content('You cannot start, change or submit applications using this account')
      end
    end

    it 'shows error message when trying delete a draft application' do
      click_on('Delete')

      within('.govuk-error-summary') do |error|
        expect(error).to have_content('You cannot start, change or submit applications using this account')
      end
    end

    it 'redirects to show page when trying to edit an application' do
      click_on('Jo Bloggs')

      within('.govuk-notification-banner') do |notice|
        expect(notice).to have_content([
          'You cannot use this account to start, change or submit applications.',
          'The crime contract linked to office account number 2A555X is currently under Contingent Liability.',
          'If you have any questions, contact your contract manager.'
        ].join("\n"))
      end
      expect(page).to have_element(:h2, text: 'Application for a criminal legal aid representation order')
    end

    it 'shows Contingent Liability notice when viewing all tabs' do
      within('.govuk-notification-banner') do |notice|
        expect(notice).to have_content('You cannot use this account to start, change or submit applications.')
      end

      click_on('Submitted')
      within('.govuk-notification-banner') do |notice|
        expect(notice).to have_content('You cannot use this account to start, change or submit applications.')
      end

      click_on('Decided')
      within('.govuk-notification-banner') do |notice|
        expect(notice).to have_content('You cannot use this account to start, change or submit applications.')
      end

      click_on('Returned')
      within('.govuk-notification-banner') do |notice|
        expect(notice).to have_content('You cannot use this account to start, change or submit applications.')
      end
    end
  end
end
