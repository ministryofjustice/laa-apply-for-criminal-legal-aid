require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid when Means Tested' do
  describe(
    'Summary only, client and partner no conflict, client employed, partner self-employed, joint income < £12,475'
  ) do
    before do
      visit root_path
      click_button('Start now')

      # steps/provider/select_office
      choose('2A555X')
      # prevent requests to the datastore for counters for tab headings on the next page
      allow_any_instance_of(Datastore::ApplicationCounters).to receive_messages(returned_count: 0)
      save_and_continue

      # applications
      click_link('Start an application')
      choose('New application')
      save_and_continue

      # edit (Task list)
      click_link('Client details')

      # steps/client/details
      fill_in('First name', with: 'Jo')
      fill_in('Last name', with: 'Bloggs')
      fill_date('Date of birth', with: 30.years.ago.to_date)
      save_and_continue

      # steps/client/is_application_means_tested
      save_and_continue

      # steps/client/case_type
      choose('Summary only')
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
      choose_answer('Does your client have a partner?', 'Yes')
      save_and_continue

      # steps/client/client_relationship_to_partner
      choose_answer('What is the client’s relationship to their partner?', 'Living together')
      save_and_continue

      # steps/partner/partner_details
      fill_in('First name', with: 'John')
      fill_in('Last name', with: 'Huffman')
      fill_date('Date of birth', with: 30.years.ago.to_date)
      save_and_continue

      # steps/partner/partner_involved_in_case
      choose_answer('Is the partner involved in your client’s case?', 'Co-defendant')
      save_and_continue

      # steps/partner/partner_conflict_of_interest
      choose_answer('Does the partner have a conflict of interest?', 'No')
      save_and_continue

      # steps/partner/nino
      choose_answer('Does the partner have a National Insurance number?', 'No')
      save_and_continue

      # steps/partner/do_client_and_partner_live_same_address
      choose_answer('Do your client and their partner live at the same address?', 'Yes')
      save_and_continue

      # steps/dwp/benefit_type
      choose_answer('Does your client get one of these passporting benefits?', 'None of these')
      save_and_continue

      # steps/dwp/partner_benefit_type
      choose_answer('Does the partner get one of these passporting benefits?', 'None of these')
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
      fill_date('When is the next hearing?', with: 1.week.from_now.to_date)
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
      choose_answers("What is your client's employment status?", ['Employed'])
      save_and_continue

      # steps/income/client/armed_forces
      choose_answer('Is your client in the armed forces?', 'No')
      save_and_continue

      # steps/income/current_income_before_tax
      choose_answer("Is your client and their partner's joint annual income more than £12,475 a year before tax?",
                    'No')
      save_and_continue

      # steps/income/income_savings_assets_under_restraint_freezing_order
      choose_answer(
        'Does your client or their partner have any income, savings or assets under a restraint or freezing order?',
        'No'
      )
      save_and_continue

      # steps/income/client/employment_income
      fill_in('What is their salary or wage?', with: '11000')
      choose_answer('Is this before or after tax?', 'Before tax')
      choose_answer('Frequency', 'Yearly')
      save_and_continue

      # steps/income/which_payments_client
      choose_answers('Which of these payments does your client get?', ['They do not get any of these payments'])
      save_and_continue

      # steps/income/which_benefits_client
      choose_answers('Which of these benefits does your client get?', ['They do not get any of these benefits'])
      save_and_continue

      # steps/income/what_is_the_partners_employment_status
      choose_answers("What is the partner's employment status?", ['Self-employed'])
      save_and_continue

      # steps/income/partner/business_type
      choose_answer('Which type of self-employed business do you want to add?', 'Self-employed business')
      save_and_continue

      # steps/income/partner/businesses/#{business_id}
      fill_in('Trading name of the business', with: 'Test Business')
      fill_in('Address line 1', with: '1 Test Street')
      fill_in('Town or city', with: 'London')
      fill_in('Country', with: 'United Kingdom')
      fill_in('Postcode', with: 'SW1 1RT')
      save_and_continue

      # steps/income/partner/nature_of_business/#{business_id}
      fill_in('Give a brief description of what the business does.', with: 'Brief business description')
      save_and_continue

      # steps/income/partner/date_business_began_trading/#{business_id}
      fill_date('When did the business begin trading?', with: 5.years.ago.to_date)
      save_and_continue

      # steps/income/partner/in_business_with_anyone_else/#{business_id}
      choose_answer('Is the partner in business with anyone else?', 'No')
      save_and_continue

      # steps/income/partner/employees/#{business_id}
      choose_answer('Does the partner employ anyone through the business?', 'No')
      save_and_continue

      # steps/income/partner/financials_of_business/#{business_id}
      fill_in('Total turnover', with: '800')
      choose('steps_income_business_financials_form[turnover_frequency]', option: 'annual')
      fill_in('Total drawings', with: '100')
      choose('steps_income_business_financials_form[drawings_frequency]', option: 'annual')
      fill_in('Total profit', with: '500')
      choose('steps_income_business_financials_form[profit_frequency]', option: 'annual')
      save_and_continue

      # steps/income/partner/businesses_summary?business_id=#{business_id}
      choose_answer('Do you need to add another business?', 'No')
      save_and_continue

      # steps/income/partner/self_assessment_partner
      choose_answer('Has the partner received a Self Assessment tax calculation in the last 2 years?', 'No')
      save_and_continue

      # steps/income/partner/other_work_benefits_partner
      # Does the partner receive any other benefits from work?
      choose('No')
      save_and_continue

      # steps/income/which_payments_partner
      choose_answers('Which of these payments does the partner get?', ['They do not get any of these payments'])
      save_and_continue

      # steps/income/which_benefits_partner
      choose_answers('Which of these benefits does the partner get?', ['They do not get any of these benefits'])
      save_and_continue
    end

    it 'lands on CYA page' do
      expect(page).to have_current_path(
        "/applications/#{CrimeApplication.first.id}/steps/income/check_your_answers_income"
      )
    end

    context 'when going through income assessment again to answer new questions' do
      before do
        # steps/income/check_your_answers_income
        click_link 'You need to complete all questions before you can submit the application'

        # #{application_id}/edit
        click_link 'Income assessment'

        # steps/income/what_is_clients_employment_status
        save_and_continue

        # steps/income/client/armed_forces
        save_and_continue

        # steps/income/current_income_before_tax
        save_and_continue

        # NO steps/income/income_savings_assets_under_restraint_freezing_order
        # NO steps/income/client/employment_income

        # steps/income/client/employer_details/#{employment_id}
        # NEW
        fill_in("Employer's name", with: 'Test Employer')
        fill_in('Address line 1', with: '98 Test Street')
        fill_in('Town or city', with: 'London')
        fill_in('Country', with: 'United Kingdom')
        fill_in('Postcode', with: 'SW1 1RT')
        save_and_continue

        # steps/income/client/employment_details/#{employment_id}
        # NEW
        fill_in('What is your client’s job title?', with: 'Worker')
        fill_in('What is their salary or wage?', with: '11000')
        choose_answer('Is this before or after tax?', 'Before tax')
        choose_answer('How often do they get this payment?', 'Yearly')
        save_and_continue

        # steps/income/client/deductions_from_pay/#{employment_id}
        # NEW
        choose_answers('Deductions', ['The client does not have deductions taken from their pay'])
        save_and_continue

        # steps/income/client/add_employments
        # NEW
        choose_answer('Do you want to add another job?', 'No')
        save_and_continue

        # steps/income/client/self_assessment_client
        # NEW
        choose_answer('Has your client received a Self Assessment tax calculation in the last 2 years?', 'No')
        save_and_continue

        # steps/income/client/other_work_benefits_client
        # NEW
        # Does your client receive any other benefits from work?
        choose('No')
        save_and_continue

        # steps/income/which_payments_client
        save_and_continue

        # steps/income/which_benefits_client
        save_and_continue

        # steps/income/does_client_have_dependants
        # NEW
        choose_answer('Does your client have any dependants?', 'No')
        save_and_continue

        # steps/income/what_is_the_partners_employment_status
        save_and_continue

        # steps/income/partner/businesses_summary
        choose_answer('Do you need to add another business?', 'No')
        save_and_continue

        # steps/income/partner/self_assessment_partner
        save_and_continue

        # steps/income/partner/other_work_benefits_partner
        save_and_continue

        # steps/income/which_payments_partner
        save_and_continue

        # steps/income/which_benefits_partner
        save_and_continue
      end

      it 'does not have validation errors' do
        # steps/income/check_your_answers_income
        expect(page).not_to have_link 'You need to complete all questions before you can submit the application'
        save_and_continue
      end

      describe 'finishing and submitting the application' do
        before do
          # steps/income/check_your_answers_income
          save_and_continue

          # OUTGOINGS ASSESSMENT

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
          choose_answer("Are your client and their partner's outgoings more than their income?", 'No')
          save_and_continue

          # steps/outgoings/check_your_answers_outgoings
          save_and_continue

          # CAPITAL ASSESSMENT

          # steps/capital/client_benefit_from_trust_fund
          choose_answer('Does your client stand to benefit from a trust fund?', 'No')
          save_and_continue

          # steps/capital/partner_benefit_from_trust_fund
          choose_answer('Does the partner stand to benefit from a trust fund?', 'No')
          save_and_continue

          # steps/capital/check_your_answers_capital
          check('Tick to confirm your client and their partner do not have any other assets or capital')
          save_and_continue

          # steps/evidence/upload
          Document.create_from_file(file: fixture_file_upload('uploads/test.pdf', 'application/pdf'),
                                    crime_application: CrimeApplication.first).update(
                                      s3_object_key: '123/abcdef1234'
                                    )
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
              body.dig('case_details', 'case_type') == 'summary_only' &&
              body.dig('client_details', 'partner', 'conflict_of_interest') == 'no' &&
              body.dig('means_details', 'income_details', 'employment_type') == ['employed'] &&
              body.dig('means_details', 'income_details', 'partner_employment_type') == ['self_employed'] &&
              body.dig('means_details', 'income_details', 'income_above_threshold') == 'no'
            }
          ).to have_been_made.once
        end
      end
    end
  end
end
