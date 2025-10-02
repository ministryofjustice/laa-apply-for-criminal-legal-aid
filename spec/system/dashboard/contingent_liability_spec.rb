require 'rails_helper'

RSpec.describe 'Viewing dashboard with Contingent Liability Criminal Legal Aid applications' do
  include_context 'when logged in'
  include_context 'with stubbed search results'

  let(:provider_data_api_response) { file_fixture('provider_data_api/contingent_liability.json').read }

  before do
    allow(FeatureFlags).to receive(:provider_data_api) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }
    stub_request(:get, 'https://pda.example.com/provider-offices/2A555X/schedules?areaOfLaw=CRIME%20LOWER')
      .to_return_json(status: 200, body: file_fixture('provider_data_api/public_defender_service.json').read)

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
    stub_request(:get, 'https://pda.example.com/provider-offices/2A555X/schedules?areaOfLaw=CRIME%20LOWER')
      .to_return_json(status: 200, body: provider_data_api_response)
    visit('/')
  end

  context 'when an office transitions to Contingent Liability' do
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
