require 'rails_helper'

RSpec.describe 'Apply for Criminal Legal Aid when age passported' do
  include_context 'when logged in'

  let(:case_type) { ['Indictable', 'Either way'].sample }

  describe 'an age passported draft' do
    before do
      draft_age_passported_application(case_type:)
    end

    it 'is passported on age when submitted' do
      click_button 'Save and submit application'

      expect(
        a_request(:post, 'http://datastore-webmock/api/v1/applications').with { |req|
          body = JSON.parse(req.body)['application']
          body['ioj_passport'] == ['on_age_under18'] && body['means_passport'] == ['on_age_under18']
        }
      ).to have_been_made.once
    end

    describe 'returning to the draft when applicant over 18' do
      before { return_to_application_later }

      context 'when Indictable' do
        let(:case_type) { 'Indictable' }

        it 'is no longer age passported' do
          expect(page).to have_content('You have completed 0 of 9 sections')
          expect(page).not_to have_link('Review the application')
        end
      end

      context 'when Either way' do
        let(:case_type) { 'Either way' }

        it 'remains age passported' do
          expect(page).to have_link('Review the application')
        end
      end
    end
  end

  describe 'a returned age passported application' do
    context 'when applicant is no longer under 18' do
      before do
        draft_age_passported_application(case_type:)
        click_button 'Save and submit application'

        visit('providers/logout')
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
    end

    describe 'when Date of Birth changed on resubmission' do
      let(:case_type) { 'Either way' }
      let(:new_age) { 17.years.ago }

      before do
        draft_age_passported_application(case_type:)
        click_button 'Save and submit application'
        return_submitted_application

        click_button('Update application')

        within_card('Client details') do |_card|
          first('a', text: 'Change').click
        end

        fill_in('Year', with: new_age)

        save_and_continue
        save_and_continue
        click_button('Save and come back later')
      end

      context 'when new age passported on date_stamp' do
        let(:new_age) { 17.years.ago }

        it 'the resubmission is age passported' do
          expect(page).to have_link('Review the application')
        end
      end

      context 'when new age not passported on date_stamp' do
        let(:new_age) { 20.years.ago }

        it 'the resubmission is age passported' do
          expect(page).not_to have_link('Review the application')
        end
      end
    end
  end
end
