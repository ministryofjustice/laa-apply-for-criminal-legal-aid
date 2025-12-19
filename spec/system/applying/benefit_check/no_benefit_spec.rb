require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid when the benefit checker is run' do
  include_context 'when logged in'

  describe 'Submitting an application where the client benefit check result is `No`' do
    before do
      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      # ClamAV is available
      allow(Open3).to receive(:capture3).and_return ['ClamAV', nil]

      # applications
      click_link('Start an application')
      choose('New application')
      save_and_continue

      # edit (Task list)
      click_link('Client details')

      # steps/client/details
      fill_in('First name', with: 'Jo')
      fill_in('Last name', with: 'BROWN')
      fill_date('What is their date of birth?', with: Date.new(1986, 0o7, 0o1))
      save_and_continue

      # steps/client/is-application-means-tested
      save_and_continue

      # steps/client/case-type
      choose('Summary only')
      save_and_continue

      # steps/client/date-stamp
      save_and_continue

      # steps/client/residence_type
      choose_answer(
        'Where does your client usually live?',
        'They do not have a fixed home address'
      )
      save_and_continue

      # steps/client/contact_details
      choose_answer('Where shall we send correspondence?', 'Provider’s office')
      save_and_continue

      # steps/client/nino
      choose_answer('Does your client have a National Insurance number?', 'Yes')
      fill_in('What is their National Insurance number?', with: 'PA435162A')
      save_and_continue

      # steps/client/does-client-have-partner
      choose_answer('Does your client have a partner?', 'No')
      save_and_continue

      # steps/client/relationship-status
      choose_answer("What is your client's relationship status?", 'Single')
      save_and_continue

      # steps/dwp/benefit-type
      mock_benefit_check('No')
      choose_answer('Does your client get one of these passporting benefits?', 'Universal Credit')
      save_and_continue

      # steps/dwp/confirm-result
      click_link('No, they do receive a passporting benefit')
      save_and_continue

      # steps/dwp/has-benefit-evidence
      choose_answer('Do you have evidence your client gets Universal Credit?', 'Yes')
      save_and_continue

      # steps/client/urn
      save_and_continue

      # steps/case/has-the-case-concluded
      choose_answer('Has the case concluded?', 'No')
      save_and_continue

      # steps/case/has-court-remanded-client-in-custody
      choose_answer('Has a court remanded your client in custody?', 'No')
      save_and_continue

      # steps/case/charges/#{charge_id}
      fill_in('Offence', with: 'Theft from a shop (Over £100,000)')
      save_and_continue

      # steps/case/charges-dates/#{charge_id}
      fill_date('Start date 1', with: 1.month.ago.to_date)
      save_and_continue

      # steps/case/charges-summary
      choose_answer('Do you want to add another offence?', 'No')
      save_and_continue

      # steps/case/has-codefendants
      choose_answer('Does your client have any co-defendants in this case?', 'No')
      save_and_continue

      # steps/case/hearing-details
      select('Derby Crown Court', from: 'What court is the hearing at?')
      fill_date('When is the next hearing', with: 1.week.from_now.to_date)
      choose_answer('Did this court also hear the first hearing?', 'Yes')
      save_and_continue

      # steps/case/ioj
      choose_answers(
        'Why should your client get legal aid?',
        ['It is likely that they will lose their livelihood']
      )
      fill_in(
        'steps-case-ioj-form-loss-of-livelihood-justification-field',
        with: 'IoJ justification details'
      )
      save_and_continue

      # steps/evidence/upload
      upload_evidence_file('test.csv')
      save_and_continue

      # steps/submission/more-information
      choose_answer('Do you want to add any other information?', 'No')
      save_and_continue

      # steps/submission/review
      expect(page).to have_content('Passporting benefit?Universal Credit')
      expect(page).to have_content('Passporting benefit check outcomeNo record of passporting benefit found')
      expect(page).not_to have_content('Confirmed details correct?Yes')
      expect(page).to have_content('Evidence can be provided?Yes')
      save_and_continue

      # steps/submission/declaration
      fill_in('First name', with: 'Zoe')
      fill_in('Last name', with: 'Bar')
      fill_in('Telephone number', with: '07715339488')

      stub_request(:post, 'http://datastore-webmock/api/v1/applications')
      click_button 'Save and submit application'
    end

    it 'submits a valid application to the datastore' do
      expect(
        a_request(:post, 'http://datastore-webmock/api/v1/applications').with { |req|
          body = JSON.parse(req.body)['application']
          body['client_details']['applicant']['benefit_type'] == 'universal_credit' &&
          body['client_details']['applicant']['confirm_details'].nil? &&
          body['client_details']['applicant']['has_benefit_evidence'] == 'yes' &&
          body['client_details']['applicant']['confirm_dwp_result'].nil? &&
          body['client_details']['applicant']['benefit_check_result'] == false &&
          body['client_details']['applicant']['benefit_check_status'] == 'no_record_found' &&
          body['client_details']['applicant']['dwp_response'] == 'No'
        }
      ).to have_been_made.once
    end
  end
end
