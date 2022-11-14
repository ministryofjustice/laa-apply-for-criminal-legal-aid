require 'rails_helper'

RSpec.describe CompletedApplicationsController, type: :controller do
  describe '#amend' do
    let(:crime_application) { CrimeApplication.create(status: :returned) }
    let(:amend_service) { instance_double(ApplicationAmendment) }

    before do
      allow(
        ApplicationAmendment
      ).to receive(:new).with(crime_application).and_return(amend_service)

      # While we figure out if this is a sensible approach or not,
      # we have the datastore submission behind a feature flag, and
      # we are not investing time on tests for code that will surely
      # change completely. Stub the feature flag to return `false`.
      allow(
        FeatureFlags
      ).to receive(:datastore_submission).and_return(double(enabled?: false))
    end

    it 'triggers the amendment of an application' do
      expect(amend_service).to receive(:call)

      put :amend, params: { id: crime_application.id }

      expect(response).to redirect_to(edit_steps_submission_review_path(crime_application))
    end
  end
end
