require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid' do
  describe 'Submitting an appeal to Crown Court application' do
    include_context 'when logged in'

    before do
      # applications
      click_link('Start an application')
      choose('New application')
      save_and_continue

      # edit (Task list)
      click_link('Client details')

      # steps/client/details
      fill_in('First name', with: 'Jo')
      fill_in('Last name', with: 'Bloggs')
      fill_date('What is their date of birth?', with: 30.years.ago.to_date)
      save_and_continue

      # steps/client/is_application_means_tested
      save_and_continue

      # steps/client/case_type
      choose('Appeal to Crown Court')
      save_and_continue

      # steps/client/appeal_details
      fill_date('When was the appeal lodged?', with: 1.month.ago.to_date)
      choose_answer('Was a legal aid application submitted for the original case?', 'Yes')
      save_and_continue

      # steps/client/financial_circumstances_changed
      choose_answer("Have your client's financial circumstances changed since the initial application?", 'No')
      save_and_continue

      # steps/client/appeal_reference_number
      choose_answer('What is the reference number of the original application?', 'MAAT ID')
      fill_in('MAAT ID', with: 1_234_567)
      save_and_continue

      # steps/client/date_stamp
      save_and_continue

      # steps/client/urn
      save_and_continue

      # steps/case/has_the_case_concluded
      choose_answer('Has the case concluded?', 'No')
      save_and_continue

      # steps/case/has_court_remanded_client_in_custody
      choose_answer('Has a court remanded your client in custody?', 'No')
      save_and_continue

      # steps/case/charges/#{charge_id}
      fill_in('Offence', with: 'Theft from a shop (Over £100,000)')
      fill_date('Start date 1', with: 1.month.ago.to_date)
      save_and_continue

      # steps/case/charges_summary
      choose_answer('Do you want to add another offence?', 'No')
      save_and_continue

      # steps/case/has_codefendants
      choose_answer('Does your client have any co-defendants in this case?', 'No')
      save_and_continue

      # steps/case/hearing_details
      select('Derby Crown Court', from: 'What court is the hearing at?')
      fill_date('When is the next hearing', with: 1.week.from_now.to_date)
      choose_answer('Did this court also hear the first hearing?', 'Yes')
      save_and_continue

      # steps/case/ioj_passport
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
      save_and_continue

      # steps/submission/more_information
      choose_answer('Do you want to add any other information?', 'No')
      save_and_continue

      # steps/submission/review
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
          body['case_details']['case_type'] == 'appeal_to_crown_court' &&
          body['case_details']['appeal_original_app_submitted'] == 'yes' &&
          body['case_details']['appeal_financial_circumstances_changed'] == 'no' &&
          body['case_details']['appeal_reference_number'] == 'appeal_maat_id'
          body['case_details']['appeal_maat_id'] == '1234567'
        }
      ).to have_been_made.once
    end
  end
end
