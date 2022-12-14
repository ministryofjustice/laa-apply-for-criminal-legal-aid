require 'rails_helper'

RSpec.describe CompletedApplicationsController, type: :controller do
  # TODO: now we are using datastore we have to figure out
  # the re-hydration etc. Disabling this spec for now.
  describe '#amend' do
    let(:crime_application) { CrimeApplication.create(status: :returned) }
    let(:amend_service) { instance_double(Datastore::ApplicationAmendment) }

    before do
      allow(
        Datastore::ApplicationAmendment
      ).to receive(:new).with(crime_application).and_return(amend_service)
    end

    it 'triggers the amendment of an application' do
      pending 're-hydration from datastore tbd'

      expect(amend_service).to receive(:call)

      put :amend, params: { id: crime_application.id }

      expect(response).to redirect_to(edit_steps_submission_review_path(crime_application))
    end
  end
end
