require 'rails_helper'

RSpec.describe 'Apply for Criminal Leagal Aid when under 18 years old' do
  describe 'Submitting a completed application' do
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
      fill_date('Date of birth', with: 17.years.ago.to_date)
      save_and_continue

      # steps/client/is_application_means_tested
      save_and_continue

      # steps/client/case_type
      choose('Indictable')
      save_and_continue

      # steps/client/residence_type
      choose('They do not have a fixed home address')
      save_and_continue

      # steps/client/contact_details
      choose('Provider’s office')
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
      fill_date('Start date 1', with: 1.month.ago.to_date)
      save_and_continue

      # steps/case/charges_summary
      choose_answer('Do you want to add another offence?', 'No')
      save_and_continue

      # steps/case/has_codefendants
      choose_answer('Does your client have any co-defendants in this case?', 'No')
      save_and_continue

      # steps/case/hearing_details
      select('Derby Crown Court', from: 'Court name')
      fill_date('Date of next hearing', with: 1.week.from_now.to_date)
      choose_answer('Did this court also hear the first hearing?', 'Yes')
      save_and_continue

      # steps/case/ioj_passport
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
          body['ioj_passport'] == ['on_age_under18'] && body['means_passport'] == ['on_age_under18']
        }
      ).to have_been_made.once
    end
  end
end
