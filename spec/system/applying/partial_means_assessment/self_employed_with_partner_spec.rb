require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid when partially means tested' do
  describe 'Submitting a means tested application with a self employed client and partner' do
    include_context 'means tested with partner'
    let(:case_type) { 'Summary only' }
    let(:full_means_assessment?) { false }

    before do
      # steps/income/what_is_clients_employment_status
      choose_answers("What is your client's employment status?", ['Self-employed'])
      save_and_continue

      # steps/income/client/business_type
      choose_answer('Which type of self-employed business do you want to add?', 'Self-employed business')
      save_and_continue

      # steps/income/client/businesses/:business_id
      fill_in('What is the trading name of the business?', with: 'Test business')
      fill_in('Address line 1', with: 'Test address line 1')
      fill_in('Address line 2', with: 'Test address line 2')
      fill_in('Town or city', with: 'Test town')
      fill_in('Country', with: 'Test Country')
      fill_in('Postcode', with: 'Test postcode')
      save_and_continue

      # steps/income/client/nature_of_business/:business_id
      fill_in('Give a brief description of what the business does', with: 'Dry cleaners')
      save_and_continue

      # steps/income/client/date_business_began_trading/:business_id
      fill_date('When did the business begin trading?', with: 1.year.ago.to_date)
      save_and_continue

      # steps/income/client/in_business_with_anyone_else/:business_id
      choose_answer('Is your client in business with anyone else?', 'No')
      save_and_continue

      # steps/income/client/employees/:business_id
      choose_answer('Does your client employ anyone through the business?', 'No')
      save_and_continue

      # steps/income/client/financials_of_business/:business_id
      fill_in('Total turnover', with: 10_000)
      fill_in('Total drawings', with: 1_000)
      fill_in('Total profit', with: 5_000)
      choose_answer_all('How often was this?', 'Monthly')
      choose_answer('Over what period was this?', 'Monthly')
      save_and_continue

      # steps/client/businesses_summary
      choose_answer('Do you need to add another business?', 'No')
      save_and_continue

      # steps/client/businesses_summary
      choose_answer('Has your client received a Self Assessment tax calculation in the last 2 years?', 'No')
      save_and_continue

      # steps/client/other_work_benefits_client
      choose_answer('Does your client receive any other benefits from work?', 'No')
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

      # steps/income/what_is_partners_employment_status
      choose_answers("What is the partner's employment status?", ['Self-employed'])
      save_and_continue

      # steps/income/partner/business_type
      choose_answer('Which type of self-employed business do you want to add?', 'Self-employed business')
      save_and_continue

      # steps/income/partner/businesses/:business_id
      fill_in('What is the trading name of the business?', with: 'Test partner business')
      fill_in('Address line 1', with: 'Test address line 1')
      fill_in('Address line 2', with: 'Test address line 2')
      fill_in('Town or city', with: 'Test town')
      fill_in('Country', with: 'Test Country')
      fill_in('Postcode', with: 'Test postcode')
      save_and_continue

      # steps/income/partner/nature_of_business/:business_id
      fill_in('Give a brief description of what the business does', with: 'Dry cleaners')
      save_and_continue

      # steps/income/partner/date_business_began_trading/:business_id
      fill_date('When did the business begin trading?', with: 1.year.ago.to_date)
      save_and_continue

      # steps/income/partner/in_business_with_anyone_else/:business_id
      choose_answer('Is the partner in business with anyone else?', 'No')
      save_and_continue

      # steps/income/partner/employees/:business_id
      choose_answer('Does the partner employ anyone through the business?', 'No')
      save_and_continue

      # steps/income/partner/financials_of_business/:business_id
      fill_in('Total turnover', with: 10_000)
      fill_in('Total drawings', with: 1_000)
      fill_in('Total profit', with: 5_000)
      choose_answer_all('How often was this?', 'Monthly')
      choose_answer('Over what period was this?', 'Monthly')
      save_and_continue

      # steps/income/partner/businesses_summary
      choose_answer('Do you need to add another business?', 'No')
      save_and_continue

      # steps/income/partner/self_assessment_partner
      choose_answer('Has the partner received a Self Assessment tax calculation in the last 2 years?', 'No')
      save_and_continue

      # steps/income/partner/other_work_benefits_partner
      choose_answer('Does the partner receive any other benefits from work?', 'No')
      save_and_continue

      # steps/income/partner/which_payments_partner
      choose_answers('Which of these payments does the partner get?', ['They do not get any of these payments'])
      save_and_continue

      # steps/income/partner/which_benefits_partner
      choose_answers('Which of these benefits does the partner get?', ['They do not get any of these benefits'])
      save_and_continue

      # income cya
      save_and_continue

      # steps/outgoings/housing_payments_where_lives
      choose_answer('Which of these payments does your client or their partner make where they usually live?',
                    'They do not make any of these payments')
      save_and_continue

      # steps/outgoings/pay_council_tax
      choose_answer('Do your client and their partner pay Council Tax where they usually live?', 'No')
      save_and_continue

      # steps/outgoings/which_payments
      choose_answers('Which of these payments do your client and their partner make?',
                     ['They do not make any of these payments'])
      save_and_continue

      # steps/outgoings/client_paid_income_tax_rate
      choose_answer('Has your client paid the 40% income tax rate in the last 2 years?', 'No')
      save_and_continue

      # steps/outgoings/partner_paid_income_tax_rate
      choose_answer('Has the partner paid the 40% income tax rate in the last 2 years?', 'No')
      save_and_continue

      # steps/outgoings/are_outgoings_more_than_income
      choose_answer("Do your client and their partner have outgoings that are more than their income?", 'No')
      save_and_continue

      # outgoings cya
      save_and_continue

      # steps/capital/client_benefit_from_trust_fund
      choose_answer('Does your client stand to benefit from a trust fund?', 'No')
      save_and_continue

      # steps/capital/partner_benefit_from_trust_fund
      choose_answer('Does the partner stand to benefit from a trust fund?', 'No')
      save_and_continue

      # steps/capital/income_savings_assets_under_restraint_freezing_order
      choose_answer(
        'Does your client or their partner have any income, savings or assets under a restraint or freezing order?',
        'No'
      )
      save_and_continue

      # capital cya
      choose_answers('Confirm the following',
                     ['Tick to confirm your client and their partner do not have any other assets or capital'])
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
      choose_answer('Do you have a signed declaration from your client’s partner?', 'Yes')

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
          body['is_means_tested'] == 'yes' &&
            body['means_details']['income_details']['partner_employment_type'] == ['self_employed'] &&
            body['means_details']['income_details']['employment_type'] == ['self_employed']
        }
      ).to have_been_made.once
    end
  end
end
