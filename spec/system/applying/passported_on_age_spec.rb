require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid when age passported' do
  include_context 'when logged in'

  context 'when indictable and applicant under 18 when drafted' do
    before do
      draft_age_passported_application(case_type: 'Indictable')
    end

    it 'submits a valid application to the datastore' do
      click_button 'Save and submit application'

      expect(
        a_request(:post, 'http://datastore-webmock/api/v1/applications').with { |req|
          body = JSON.parse(req.body)['application']
          body['ioj_passport'] == ['on_age_under18'] && body['means_passport'] == ['on_age_under18']
        }
      ).to have_been_made.once
    end

    describe 'returning to the draft when applicant over 18' do
      before do
        return_to_application_later
      end

      it 'shows the previously passported sections as incomplete' do
        expect(page).to have_content('You have completed 0 of 9 sections')
        expect(page).not_to have_link('Review the application')
      end
    end
  end

  context 'when date_stampable and applicant under 18 when drafted' do
    before do
      draft_age_passported_application(case_type: 'Either way')
    end

    it 'submits a valid application to the datastore' do
      click_button 'Save and submit application'

      expect(
        a_request(:post, 'http://datastore-webmock/api/v1/applications').with { |req|
          body = JSON.parse(req.body)['application']
          body['ioj_passport'] == ['on_age_under18'] && body['means_passport'] == ['on_age_under18']
        }
      ).to have_been_made.once
    end

    describe 'returning to the draft when applicant over 18' do
      before do
        return_to_application_later
      end

      it 'previously passported sections remain passported' do
        click_link('Review the application')
        save_and_continue
      end
    end
  end
end
