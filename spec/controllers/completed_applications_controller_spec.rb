require 'rails_helper'

RSpec.describe CompletedApplicationsController, type: :controller do
  describe '#amend' do
    let(:crime_application) { CrimeApplication.create(status: :returned) }
    let(:amend_service) { instance_double(ApplicationAmendment) }

    before do
      allow(
        ApplicationAmendment
      ).to receive(:new).with(crime_application).and_return(amend_service)

      # TODO: we don't know yet how the re-hydration will work
      # Disabling the datastore feature in this spec for now
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
