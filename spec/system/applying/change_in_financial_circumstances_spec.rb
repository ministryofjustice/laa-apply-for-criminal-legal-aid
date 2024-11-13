require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid' do
  describe 'Submitting a change in financial circumstances application' do
    include_context 'when logged in'

    before do
      # applications
      click_link('Start an application')
      choose('A change in financial circumstances')
      save_and_continue

      # steps/circumstances/pre_cifc_reference_number
      choose_answer('What is the reference number of the original application?', 'MAAT ID')
      fill_in('Enter MAAT ID', with: '1234567')
      save_and_continue

      # steps/circumstances/pre_cifc_reason
      fill_in("What has changed in your client's financial circumstances?", with: 'Redundancy')
      save_and_continue

      # steps/client/details
      fill_in('First name', with: 'Jo')
      fill_in('Last name', with: 'Bloggs')
      fill_date('Date of birth', with: 30.years.ago.to_date)
      save_and_continue

      # steps/client/case_type
      choose('Indictable')
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
      choose('No')

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
      choose_answer("Are your client's outgoings more than their income?", 'No')
      save_and_continue

      # outgoings cya
      save_and_continue

      # steps/capital/which_assets_owned
      choose_answer('Which assets does your client own or part-own inside or outside the UK?',
                    'They do not own any of these assets')
      save_and_continue

      # steps/capital/which_savings
      choose_answer('Which savings do your client have inside or outside the UK?',
                    'They do not have any of these savings')
      save_and_continue

      # steps/capital/client_any_premium_bonds
      choose_answer('Does your client have any Premium Bonds?', 'No')
      save_and_continue

      # steps/capital/any_national_savings_certificates
      choose_answer('Does your client have any National Savings Certificates?', 'No')
      save_and_continue

      # steps/capital/which_investments
      choose_answer('Which investments does your client have inside or outside the UK?',
                    'They do not have any of these investments')
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
      # to bypass evidence validation requirements
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive_messages(validate: true,
                                                                                      evidence_complete?: true)
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
          body['application_type'] == 'change_in_financial_circumstances'
        }
      ).to have_been_made.once
    end
  end
end
