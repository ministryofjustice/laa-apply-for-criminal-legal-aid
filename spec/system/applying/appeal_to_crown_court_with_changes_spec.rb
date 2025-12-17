require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid' do
  describe 'Submitting an appeal to Crown Court (with changes) application' do
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
      choose_answer("Have your client's financial circumstances changed since the initial application?", 'Yes')
      fill_in("What has changed in your client's financial circumstances?", with: 'Redundancy')
      save_and_continue

      # steps/client/date_stamp
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
      choose_answer('Does your client have a National Insurance number?', 'No')
      save_and_continue

      # steps/client/does_client_have_partner
      choose_answer('Does your client have a partner?', 'No')
      save_and_continue

      # steps/client/relationship_status
      choose_answer("What is your client's relationship status?", 'Single')
      save_and_continue

      # steps/dwp/benefit_type
      choose_answer('Does your client get one of these passporting benefits?', 'None of these')
      save_and_continue

      # steps/client/urn
      save_and_continue

      # steps/case/has_the_case_concluded
      choose_answer('Has the case concluded?', 'No')
      save_and_continue

      # steps/case/haas_court_remanded_client_in_custody
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

      # steps/income/what_is_clients_employment_status
      choose_answers("What is your client's employment status?", ['Not working'])
      choose_answer('Has your client ended employment in the last 3 months?', 'No')
      save_and_continue

      # steps/income/current_income_before_tax
      choose_answer("Is your client's annual income currently more than £12,475 a year before tax?", 'Yes')
      save_and_continue

      # steps/income/which_payments_client
      choose_answers('Which of these payments does your client get?', ['They do not get any of these payments'])
      save_and_continue

      # steps/income/which_benefits_client
      choose_answers('Which of these benefits does your client get?', ['They do not get any of these benefits'])
      save_and_continue

      # steps/income/does_client_have_dependants
      choose_answer('Does your client have any dependants?', 'No')
      save_and_continue

      # steps/income/how_manage_with_no_income
      choose_answer('How does your client manage with no income?', 'They stay with family for free')
      save_and_continue

      # income cya
      save_and_continue

      # steps/outgoings/housing_payments_where_lives
      choose_answer('Which of these payments does your client make where they usually live?',
                    'They do not make any of these payments')
      save_and_continue

      # steps/outgoings/pay_council_tax
      choose_answer('Does your client pay Council Tax where they usually live?', 'No')
      save_and_continue

      # steps/outgoings/which_payments
      choose_answers('Which of these payments does your client make?',
                     ['They do not make any of these payments'])
      save_and_continue

      # steps/outgoings/client_paid_income_tax_rate
      choose_answer('Has your client paid the 40% income tax rate in the last 2 years?', 'No')
      save_and_continue

      # steps/outgoings/are_outgoings_more_than_income
      choose_answer('Does your client have outgoings that are more than their income?', 'No')
      save_and_continue

      # outgoings cya
      save_and_continue

      # steps/capital/client_benefit_from_trust_fund
      choose_answer('Does your client stand to benefit from a trust fund?', 'No')
      save_and_continue

      # steps/capital/income_savings_assets_under_restraint_freezing_order
      choose_answer(
        'Does your client have any income, savings or assets under a restraint or freezing order?',
        'No'
      )
      save_and_continue

      # capital cya
      choose_answers('Confirm the following',
                     ['Tick to confirm your client does not have any other assets or capital'])
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
          body['case_details']['case_type'] == 'appeal_to_crown_court_with_changes' &&
          body['case_details']['appeal_original_app_submitted'] == 'yes' &&
          body['case_details']['appeal_financial_circumstances_changed'] == 'yes' &&
          body['case_details']['appeal_with_changes_details'] == 'Redundancy'
        }
      ).to have_been_made.once
    end
  end
end
