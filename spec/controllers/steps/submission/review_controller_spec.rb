require 'rails_helper'

RSpec.describe Steps::Submission::ReviewController, type: :controller do
  include_context 'current provider with active office'
  context 'when applicant details not set' do
    let(:existing_case) { CrimeApplication.create(office_code:) }

    before do
      allow(Rails.error).to receive(:report)
      get :edit, params: { id: existing_case.id }
    end

    it 'redirects to the task list' do
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(edit_crime_application_path)
    end

    it 'reports the Dry Struct error' do
      expect(Rails.error).to have_received(:report).with(
        kind_of(Dry::Struct::Error), { handled: true }
      )
    end
  end

  context 'when applicant name and age are known' do
    let(:existing_case) {
      CrimeApplication.create(
        office_code: office_code,
        applicant: Applicant.new(
          first_name: 'Bob',
          last_name: 'Smith',
          date_of_birth: '2000-01-01'
        )
      )
    }

    it_behaves_like 'a generic step controller', Steps::Submission::ReviewForm, Decisions::SubmissionDecisionTree
  end
end
