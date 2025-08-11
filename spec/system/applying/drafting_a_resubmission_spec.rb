require 'rails_helper'

RSpec.describe 'Drafting a resubmision' do
  include_context 'when logged in'

  context 'when updating a returned application' do
    before do
      draft_age_passported_application
      submit_drafted_application
      return_submitted_application
    end

    it 'redirects to the review screen, or--if a draft exists--the task list' do
      click_button('Update application')
      expect(page).to have_element(:h1, text: 'Review the application')

      visit_returned_application
      click_button('Update application')
      expect(page).to have_element(:h1, text: 'Make a new application')
    end
  end
end
