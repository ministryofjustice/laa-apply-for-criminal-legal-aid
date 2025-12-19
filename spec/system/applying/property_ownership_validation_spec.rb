require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid with cross-question property ownership validation' do
  include_context 'when logged in'

  describe 'Submitting a means tested application with an employed client who owns a property' do
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

      # steps/client/is-application-means-tested
      save_and_continue

      # steps/client/case-type
      choose('Either way')
      save_and_continue

      # steps/client/date-stamp
      save_and_continue

      # steps/client/residence-type
      choose_answer(
        'Where does your client usually live?',
        'In a property they own'
      )
      save_and_continue

      # steps/address/lookup/{address_id}
      click_link('Enter address manually')

      # steps/address/details/{address_id}
      fill_in('Address line 1', with: '1 Test Road')
      fill_in('Town or city', with: 'London')
      fill_in('Country', with: 'United Kingdom')
      fill_in('Postcode', with: 'SW1 1RT')
      save_and_continue

      # steps/client/contact-details
      choose_answer('Where shall we send correspondence?', 'Same as usual home address')
      save_and_continue

      # steps/client/nino
      choose_answer('Does your client have a National Insurance number?', 'No')
      save_and_continue

      # steps/client/does-client-have-partner
      choose_answer('Does your client have a partner?', 'No')
      save_and_continue

      # steps/client/relationship-status
      choose_answer("What is your client's relationship status?", 'Single')
      save_and_continue

      # steps/dwp/benefit-type
      choose_answer('Does your client get one of these passporting benefits?', 'None of these')
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

      # steps/case/client/other-charge-in-progress
      choose_answer('Is any other criminal case or charge against your client in progress?', 'No')
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

      # steps/income/what-is-clients-employment-status
      choose_answers("What is your client's employment status?", ['Employed'])
      save_and_continue

      # steps/income/client/armed-forces
      choose_answer('Is your client in the armed forces?', 'No')
      save_and_continue

      # steps/income/current-income-before-tax
      choose_answer("Is your client's annual income currently more than £12,475 a year before tax?",
                    'No')
      save_and_continue

      # steps/income/income-savings-assets-under-restraint-freezing-order
      choose_answer(
        'Does your client have any income, savings or assets under a restraint or freezing order?',
        'No'
      )
      save_and_continue

      # steps/income/client/employer-details/#{employment_id}
      fill_in("Employer's name", with: 'Test Employer')
      fill_in('Address line 1', with: '98 Test Street')
      fill_in('Town or city', with: 'London')
      fill_in('Country', with: 'United Kingdom')
      fill_in('Postcode', with: 'SW1 1RT')
      save_and_continue

      # steps/income/client/employment-details/#{employment_id}
      fill_in('What is your client’s job title?', with: 'Worker')
      fill_in('What is their salary or wage?', with: '11000')
      choose_answer('Is this before or after tax?', 'Before tax')
      choose_answer('How often do they get this payment?', 'Yearly')
      save_and_continue

      # steps/income/client/deductions-from-pay/#{employment_id}
      choose_answers('Deductions', ['The client does not have deductions taken from their pay'])
      save_and_continue

      # steps/income/client/add-employments
      choose_answer('Do you want to add another job?', 'No')
      save_and_continue

      # steps/income/client/self-assessment-client
      choose_answer('Has your client received a Self Assessment tax calculation in the last 2 years?', 'No')
      save_and_continue

      # steps/income/client/other-work-benefits-client
      choose_answer('Does your client receive any other benefits from work?', 'No')
      save_and_continue

      # steps/income/which-payments-client
      choose_answers('Which of these payments does your client get?', ['They do not get any of these payments'])
      save_and_continue

      # steps/income/which-benefits-client
      choose_answers('Which of these benefits does your client get?', ['They do not get any of these benefits'])
      save_and_continue

      # steps/income/does-client-have-dependants
      choose_answer('Does your client have any dependants?', 'No')
      save_and_continue

      # steps/income/check-your-answers-income
      save_and_continue

      # steps/outgoings/housing-payments-where-lives
      choose_answer('Which of these payments does your client make where they usually live?',
                    'They do not make any of these payments')
      save_and_continue

      # steps/outgoings/pay-council-tax
      choose_answer('Does your client pay Council Tax where they usually live?', 'No')
      save_and_continue

      # steps/outgoings/which-payments
      choose_answers('Which of these payments does your client make?',
                     ['They do not make any of these payments'])
      save_and_continue

      # steps/outgoings/client-paid-income-tax-rate
      choose_answer('Has your client paid the 40% income tax rate in the last 2 years?', 'No')
      save_and_continue

      # steps/outgoings/are-outgoings-more-than-income
      choose_answer('Does your client have outgoings that are more than their income?', 'No')
      save_and_continue

      # steps/outgoings/check-your-answers-outgoings
      save_and_continue

      # steps/capital/which-assets-owned
      choose_answer('Which assets does your client own or part-own inside or outside the UK?',
                    'They do not own any of these assets')
      save_and_continue

      # steps/capital/usual-property-details
      choose_answer('What do you want to do next?', 'Provide the details of this property')
      save_and_continue

      # steps/capital/residential-property/{property_id}
      choose_answer('Which type of property is it?', 'Terraced')
      fill_in('How many bedrooms are there?', with: '2')
      fill_in('How much is the property worth?', with: '540000')
      fill_in('How much is left to pay on the mortgage?', with: '100000')
      fill_in('What percentage of the property does your client own?', with: '100')
      choose_answer('Is the address of the property the same as your client’s home address?', 'Yes')
      choose_answer('Does anyone else own part of the property?', 'No')
      save_and_continue

      # steps/capital/add-assets
      choose_answer('Do you want to add another asset?', 'No')
      save_and_continue

      # steps/capital/which-savings
      choose_answer('Which savings do your client have inside or outside the UK?',
                    'They do not have any of these savings')
      save_and_continue

      # steps/capital/client-any-premium-bonds
      choose_answer('Does your client have any Premium Bonds?', 'No')
      save_and_continue

      # steps/capital/any-national-savings-certificates
      choose_answer('Does your client have any National Savings Certificates?', 'No')
      save_and_continue

      # steps/capital/which-investments
      choose_answer('Which investments does your client have inside or outside the UK?',
                    'They do not have any of these investments')
      save_and_continue

      # steps/capital/client-benefit-from-trust-fund
      choose_answer('Does your client stand to benefit from a trust fund?', 'No')
      save_and_continue

      # steps/capital/check-your-answers-capital
      choose_answers('Confirm the following',
                     ['Tick to confirm your client does not have any other assets or capital'])
      save_and_continue

      # steps/evidence/upload
      Document.create_from_file(file: fixture_file_upload('uploads/test.pdf', 'application/pdf'),
                                crime_application: CrimeApplication.first).update(
                                  s3_object_key: '123/abcdef1234'
                                )
      save_and_continue

      # steps/submission/more-information
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
          body['client_details']['applicant']['residence_type'] == 'applicant_owned' &&
          body['means_details']['income_details']['client_owns_property'].nil? &&
          body['means_details']['capital_details']['properties'].first['is_home_address'] == 'yes' &&
          body['means_details']['capital_details']['has_no_properties'].nil?
        }
      ).to have_been_made.once
    end
  end

  describe "Submitting a means tested application with an employed client who lives in partner's property with CoI" do
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

      # steps/client/is-application-means-tested
      save_and_continue

      # steps/client/case-type
      choose('Either way')
      save_and_continue

      # steps/client/date-stamp
      save_and_continue

      # steps/client/residence-type
      choose_answer(
        'Where does your client usually live?',
        'In a property their partner owns'
      )
      save_and_continue

      # steps/address/lookup/{address_id}
      click_link('Enter address manually')

      # steps/address/details/{address_id}
      fill_in('Address line 1', with: '1 Test Road')
      fill_in('Town or city', with: 'London')
      fill_in('Country', with: 'United Kingdom')
      fill_in('Postcode', with: 'SW1 1RT')
      save_and_continue

      # steps/client/contact-details
      choose_answer('Where shall we send correspondence?', 'Same as usual home address')
      save_and_continue

      # steps/client/nino
      choose_answer('Does your client have a National Insurance number?', 'No')
      save_and_continue

      # steps/client/does-client-have-partner
      choose_answer('Does your client have a partner?', 'Yes')
      save_and_continue

      # steps/partner/client-relationship-to-partner
      choose_answer('What is your client’s relationship to their partner?', 'Married or in a civil partnership')
      save_and_continue

      # steps/partner/partner-details
      fill_in('First name', with: 'John')
      fill_in('Last name', with: 'Huffman')
      fill_date("What is the partner's date of birth?", with: 19.years.ago.to_date)
      save_and_continue

      # steps/partner/partner-involved-in-case
      choose_answer('Is the partner involved in your client’s case?', 'Co-defendant')
      save_and_continue

      # steps/partner/partner-conflict-of-interest
      choose_answer('Does the partner have a conflict of interest?', 'Yes')
      save_and_continue

      # steps/dwp/benefit-type
      choose_answer('Does your client get one of these passporting benefits?', 'None of these')
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

      # steps/case/client/other-charge-in-progress
      choose_answer('Is any other criminal case or charge against your client in progress?', 'No')
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

      # steps/income/what-is-clients-employment-status
      choose_answers("What is your client's employment status?", ['Employed'])
      save_and_continue

      # steps/income/client/armed-forces
      choose_answer('Is your client in the armed forces?', 'No')
      save_and_continue

      # steps/income/current-income-before-tax
      choose_answer("Is your client's annual income currently more than £12,475 a year before tax?",
                    'No')
      save_and_continue

      # steps/income/income-savings-assets-under-restraint-freezing-order
      choose_answer(
        'Does your client have any income, savings or assets under a restraint or freezing order?',
        'No'
      )
      save_and_continue

      # steps/income/own-home-land-property
      choose_answer('Does your client own their home, or any other land or property?', 'No')
      save_and_continue

      # steps/income/any-savings-investments
      choose_answer('Does your client have any savings or investments?', 'Yes')
      save_and_continue

      # steps/income/client/employer-details/#{employment_id}
      fill_in("Employer's name", with: 'Test Employer')
      fill_in('Address line 1', with: '98 Test Street')
      fill_in('Town or city', with: 'London')
      fill_in('Country', with: 'United Kingdom')
      fill_in('Postcode', with: 'SW1 1RT')
      save_and_continue

      # steps/income/client/employment-details/#{employment_id}
      fill_in('What is your client’s job title?', with: 'Worker')
      fill_in('What is their salary or wage?', with: '11000')
      choose_answer('Is this before or after tax?', 'Before tax')
      choose_answer('How often do they get this payment?', 'Yearly')
      save_and_continue

      # steps/income/client/deductions-from-pay/#{employment_id}
      choose_answers('Deductions', ['The client does not have deductions taken from their pay'])
      save_and_continue

      # steps/income/client/add-employments
      choose_answer('Do you want to add another job?', 'No')
      save_and_continue

      # steps/income/client/self-assessment-client
      choose_answer('Has your client received a Self Assessment tax calculation in the last 2 years?', 'No')
      save_and_continue

      # steps/income/client/other-work-benefits-client
      choose_answer('Does your client receive any other benefits from work?', 'No')
      save_and_continue

      # steps/income/which-payments-client
      choose_answers('Which of these payments does your client get?', ['They do not get any of these payments'])
      save_and_continue

      # steps/income/which-benefits-client
      choose_answers('Which of these benefits does your client get?', ['They do not get any of these benefits'])
      save_and_continue

      # steps/income/does-client-have-dependants
      choose_answer('Does your client have any dependants?', 'No')
      save_and_continue

      # steps/income/check-your-answers-income
      save_and_continue

      # steps/outgoings/housing-payments-where-lives
      choose_answer('Which of these payments does your client make where they usually live?',
                    'They do not make any of these payments')
      save_and_continue

      # steps/outgoings/pay-council-tax
      choose_answer('Does your client pay Council Tax where they usually live?', 'No')
      save_and_continue

      # steps/outgoings/which-payments
      choose_answers('Which of these payments does your client make?',
                     ['They do not make any of these payments'])
      save_and_continue

      # steps/outgoings/client-paid-income-tax-rate
      choose_answer('Has your client paid the 40% income tax rate in the last 2 years?', 'No')
      save_and_continue

      # steps/outgoings/are-outgoings-more-than-income
      choose_answer('Does your client have outgoings that are more than their income?', 'No')
      save_and_continue

      # steps/outgoings/check-your-answers-outgoings
      save_and_continue

      # steps/capital/which-assets-owned
      choose_answer('Which assets does your client own or part-own inside or outside the UK?',
                    'They do not own any of these assets')
      save_and_continue

      # steps/capital/which-savings
      choose_answer('Which savings do your client have inside or outside the UK?',
                    'They do not have any of these savings')
      save_and_continue

      # steps/capital/client-any-premium-bonds
      choose_answer('Does your client have any Premium Bonds?', 'No')
      save_and_continue

      # steps/capital/any-national-savings-certificates
      choose_answer('Does your client have any National Savings Certificates?', 'No')
      save_and_continue

      # steps/capital/which-investments
      choose_answer('Which investments does your client have inside or outside the UK?',
                    'They do not have any of these investments')
      save_and_continue

      # steps/capital/client-benefit-from-trust-fund
      choose_answer('Does your client stand to benefit from a trust fund?', 'No')
      save_and_continue

      # steps/capital/check-your-answers-capital
      choose_answers('Confirm the following',
                     ['Tick to confirm your client does not have any other assets or capital'])
      save_and_continue

      # steps/evidence/upload
      Document.create_from_file(file: fixture_file_upload('uploads/test.pdf', 'application/pdf'),
                                crime_application: CrimeApplication.first).update(
                                  s3_object_key: '123/abcdef1234'
                                )
      save_and_continue

      # steps/submission/more-information
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
          body['client_details']['applicant']['residence_type'] == 'partner_owned' &&
          body['means_details']['income_details']['client_owns_property'] == 'no' &&
          body['means_details']['capital_details']['properties'].empty? &&
          body['means_details']['capital_details']['has_no_properties'] = 'yes'
        }
      ).to have_been_made.once
    end
  end

  describe 'Updating the residence type of a returned means tested application' do
    let(:datastore_query) do
      {
        'search' => {
          'search_text' => nil,
          'review_status' => nil,
          'status' => ['returned'],
          'office_code' => '2A555X'
        },
        'pagination' => {
          'page' => 1,
          'per_page' => 30
        },
        'sorting' => {
          'sort_direction' => 'descending',
          'sort_by' => 'submitted_at'
        }
      }
    end

    let(:returned_applications_list) do
      {
        'pagination' => {
          'total_pages' => 1,
          'current_page' => 1,
          'total_count' => 1
        },
        'sorting' => {
          'sort_direction' => 'descending',
          'sort_by' => 'submitted_at'
        },
        'records' => [
          {
            'resource_id' => 'f0a37089-1933-452d-897e-4f8d3fcf2d21',
            'submitted_at' => '2025-01-17T13:08:42.299Z',
            'reviewed_at' => '2025-01-17T14:09:28.956Z',
            'applicant_name' => 'Jo Bloggs',
            'reference' => 1,
            'status' => 'returned',
            'review_status' => 'returned_to_provider',
            'parent_id' => nil,
            'work_stream' => 'criminal_applications_team',
            'return_reason' => 'clarification_required',
            'return_details' => 'More info needed',
            'office_code' => '2A555X',
            'provider_name' => '',
            'application_type' => 'initial',
            'case_type' => 'indictable',
            'means_passport' => []
          }
        ]
      }
    end

    let(:returned_application) do
      application = JSON.parse(file_fixture('applications/either-way-means-minimal.json').read)
      application.merge(
        'status' => 'returned',
        'reviewed_at' => '2025-01-19T12:01:28.956Z',
        'created_at' => '2025-01-17T13:07:42.401Z',
        'work_stream' => 'criminal_applications_team',
        'returned_at' => '2025-01-19T12:03:28.956Z',
        'return_details' => { 'reason' => 'clarification_required', 'details' => 'More info needed' },
        'decisions' => []
      )
    end

    before do
      stub_request(:post, 'http://datastore-webmock/api/v1/searches')
        .with(body: datastore_query)
        .to_return(body: returned_applications_list.to_json)

      stub_request(:get, 'http://datastore-webmock/api/v1/applications/f0a37089-1933-452d-897e-4f8d3fcf2d21')
        .to_return(body: returned_application.to_json)

      # /applications
      click_link('Returned')

      # /completed/applications?q=returned#tab
      click_link('Jo Bloggs')

      # /completed/applications/f0a37089-1933-452d-897e-4f8d3fcf2d21
      click_button('Update application')

      # /applications/f0a37089-1933-452d-897e-4f8d3fcf2d21/steps/submission/review
      within('.govuk-summary-list__row', text: 'Where the client usually lives') do
        click_link('Change')
      end

      # /steps/client/residence-type
      choose_answer(
        'Where does your client usually live?',
        'In a property they own'
      )
      save_and_continue

      # steps/address/details/{address_id}
      save_and_continue

      # steps/client/contact-details
      choose_answer('Where shall we send correspondence?', 'Same as usual home address')
      save_and_continue

      # steps/client/nino
      save_and_continue

      # steps/client/does-client-have-partner
      save_and_continue

      # steps/client/relationship-status
      save_and_continue

      # steps/dwp/benefit-type
      choose_answer('Does your client get one of these passporting benefits?', 'None of these')
      save_and_continue

      # steps/case/urn
      save_and_continue

      # steps/case/has-the-case-concluded
      save_and_continue

      # steps/case/has-court-remanded-client-in-custody
      save_and_continue

      # steps/case/charges-summary
      choose_answer('Do you want to add another offence?', 'No')
      save_and_continue

      # steps/case/has-codefendants
      save_and_continue

      # steps/case/client/other-charge-in-progress
      save_and_continue

      # steps/case/hearing-details
      save_and_continue

      # steps/case/ioj
      save_and_continue

      # steps/income/what-is-clients-employment-status
      save_and_continue

      # steps/income/current-income-before-tax
      save_and_continue

      # steps/income/which-payments-client
      save_and_continue

      # steps/income/which-benefits-client
      save_and_continue

      # steps/income/does-client-have-dependants
      choose_answer('Does your client have any dependants?', 'No')
      save_and_continue

      # steps/income/how-manage-with-no-income
      save_and_continue

      # steps/income/check-your-answers-income
      save_and_continue

      # steps/outgoings/housing-payments-where-lives
      choose_answer('Which of these payments does your client make where they usually live?',
                    'They do not make any of these payments')
      save_and_continue

      # steps/outgoings/pay-council-tax
      choose_answer('Does your client pay Council Tax where they usually live?', 'No')
      save_and_continue

      # steps/outgoings/which-payments
      choose_answers('Which of these payments does your client make?',
                     ['They do not make any of these payments'])
      save_and_continue

      # steps/outgoings/client-paid-income-tax-rate
      choose_answer('Has your client paid the 40% income tax rate in the last 2 years?', 'No')
      save_and_continue

      # steps/outgoings/are-outgoings-more-than-income
      choose_answer('Does your client have outgoings that are more than their income?', 'No')
      save_and_continue

      # steps/outgoings/check-your-answers-outgoings
      save_and_continue

      # steps/capital/which-assets-owned
      choose_answer('Which assets does your client own or part-own inside or outside the UK?',
                    'They do not own any of these assets')
      save_and_continue

      # steps/capital/usual-property-details
      choose_answer('What do you want to do next?', 'Provide the details of this property')
      save_and_continue

      # steps/capital/residential-property/{property_id}
      choose_answer('Which type of property is it?', 'Terraced')
      fill_in('How many bedrooms are there?', with: '2')
      fill_in('How much is the property worth?', with: '540000')
      fill_in('How much is left to pay on the mortgage?', with: '100000')
      fill_in('What percentage of the property does your client own?', with: '100')
      choose_answer('Is the address of the property the same as your client’s home address?', 'Yes')
      choose_answer('Does anyone else own part of the property?', 'No')
      save_and_continue

      # steps/capital/add-assets
      choose_answer('Do you want to add another asset?', 'No')
      save_and_continue

      # steps/capital/which-savings
      choose_answer('Which savings do your client have inside or outside the UK?',
                    'They do not have any of these savings')
      save_and_continue

      # steps/capital/client-any-premium-bonds
      choose_answer('Does your client have any Premium Bonds?', 'No')
      save_and_continue

      # steps/capital/any-national-savings-certificates
      choose_answer('Does your client have any National Savings Certificates?', 'No')
      save_and_continue

      # steps/capital/which-investments
      choose_answer('Which investments does your client have inside or outside the UK?',
                    'They do not have any of these investments')
      save_and_continue

      # steps/capital/client-benefit-from-trust-fund
      choose_answer('Does your client stand to benefit from a trust fund?', 'No')
      save_and_continue

      # steps/capital/check-your-answers-capital
      choose_answers('Confirm the following',
                     ['Tick to confirm your client does not have any other assets or capital'])
      save_and_continue

      # steps/evidence/upload
      save_and_continue

      # steps/submission/more-information
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
          body['client_details']['applicant']['residence_type'] == 'applicant_owned' &&
          body['means_details']['income_details']['client_owns_property'].nil? &&
          body['means_details']['capital_details']['properties'].first['is_home_address'] == 'yes' &&
          body['means_details']['capital_details']['has_no_properties'].nil?
        }
      ).to have_been_made.once
    end
  end
end
