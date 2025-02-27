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

  context 'when date_stampable and applicant under 18 when date_stamped' do
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
        expect(page).not_to have_content I18n.t('errors.incomplete_records')
      end
    end
  end

  describe 'resubmitting a previously age passported application when now over 18' do
    before do
      draft_age_passported_application(case_type:)
      click_button 'Save and submit application'

      click_link('Sign out')
      travel 1.week

      visit root_path
      click_button('Start now')
      choose('Yes')
      return_submitted_application

      click_button('Update application')
    end

    context 'when Indictable' do
      let(:case_type) { 'Indictable' }

      it 'the resubmission is not age passported' do
        expect(page).to have_content I18n.t('errors.incomplete_records')
      end
    end

    context 'when Either way' do
      let(:case_type) { 'Either way' }

      it 'the resubmission is age passported' do
        expect(page).not_to have_content I18n.t('errors.incomplete_records')
      end
    end

    context 'when the Date of Birth changed so origional would not have been passported' do
      let(:case_type) { 'Either way' }

      before do
        within_card('Client details') do |card|
          first('a', text: 'Change').click
        end
        fill_in('Year', with: 2000)
        save_and_continue
        save_and_continue
        click_button('Save and come back later')
        expect(page).to have_text 'You have completed 0 of 9 sections'
      end
    end
  end
end
