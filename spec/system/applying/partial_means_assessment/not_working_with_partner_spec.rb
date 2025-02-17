require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid when partially means tested' do
  describe 'Submitting a means tested application with a not working client and partner' do
    include_context 'means tested with partner'
    let(:case_type) { 'Summary only' }
    let(:full_means_assessment?) { false }

    before do
      # steps/income/what_is_clients_employment_status
      choose_answers("What is your client's employment status?", ['Not working'])
      choose_answer('Has your client ended employment in the last 3 months?', 'No')
      save_and_continue

      # steps/income/current_income_before_tax
      choose_answer("Is your client and their partner's joint annual income more than £12,475 a year before tax", 'Yes')
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
      choose_answers("What is the partner's employment status?", ['Not working'])
      save_and_continue

      # steps/income/partner/which_payments_partner
      choose_answers('Which of these payments does the partner get?', ['They do not get any of these payments'])
      save_and_continue

      # steps/income/partner/which_benefits_partner
      choose_answers('Which of these benefits does the partner get?', ['They do not get any of these benefits'])
      save_and_continue

      # steps/income/how_manage_with_no_income
      choose_answer('How do your client and their partner manage with no income?', 'They stay with family for free')
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
            body['means_details']['income_details']['partner_employment_type'] == ['not_working'] &&
            body['means_details']['income_details']['employment_type'] == ['not_working']
        }
      ).to have_been_made.once
    end
  end
end
