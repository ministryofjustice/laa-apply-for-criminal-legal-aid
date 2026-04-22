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
      save_and_continue

      # steps/case/charges-dates/#{charge_id}
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
    end

    it 'submits a valid application to the datastore' do
      save_and_continue
      # steps/submission/declaration
      fill_in('First name', with: 'Zoe')
      fill_in('Last name', with: 'Bar')
      fill_in('Telephone number', with: '07715339488')

      stub_request(:post, 'http://datastore-webmock/api/v1/applications')
      click_button 'Save and submit application'
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

    # INC4196794 - Means details missing from Review
    context 'when the original case answer changed to no' do
      it 'requires client and means details and hides original application details' do # rubocop:disable RSpec/ExampleLength
        expect(summary_card('Case details')).to have_rows(
          'Case type', 'Appeal to Crown Court',
          'Legal aid application for original case?', 'Yes',
          'Original application MAAT ID', '1234567'
        )

        within(summary_card('Case details')) do
          click_link('Change Legal aid application for original case?', match: :first)
        end
        choose_answer('Was a legal aid application submitted for the original case?', 'No')
        click_button 'Save and come back later'

        # confirm that the task list show client details as in progres
        expect(task_list_item_status('Client details')).to have_text('In progress')

        # return to the original case details having checked the task item status
        visit(crime_application_path(CrimeApplication.last))
        within(summary_card('Case details')) do
          click_link('Change Legal aid application for original case?', match: :first)
        end
        save_and_continue

        # because the original application no longer exists, client address and means
        # details are required
        expect(page).to have_content('Where does your client usually live?')
        save_and_continue
        save_and_continue
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
        fill_in('What is their National Insurance number?', with: 'JA293483A')
        save_and_continue

        # steps/client/does-client-have-partner
        choose_answer('Does your client have a partner?', 'No')
        save_and_continue

        # steps/client/relationship-status
        choose_answer("What is your client's relationship status?", 'Single')
        save_and_continue

        # steps/dwp/benefit-type
        mock_benefit_check('Yes')
        choose_answer('Does your client get one of these passporting benefits?', 'Universal Credit')
        save_and_continue

        # steps/dwp/benefit-check-result
        save_and_continue

        # steps/client/urn
        save_and_continue
        click_button 'Save and come back later'
        expect(task_list_item_status('Client details')).to have_text('Completed')

        within(task_list_item('Review the application')) do
          click_link
        end

        expect(summary_card('Case details')).to have_rows(
          'Case type', 'Appeal to Crown Court',
          'Legal aid application for original case?', 'No'
        )
        expect(page).not_to have_content('Original application')
      end
    end
  end
end
