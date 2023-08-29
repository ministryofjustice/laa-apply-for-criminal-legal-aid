require 'rails_helper'

RSpec.describe Steps::Evidence::UploadController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Evidence::UploadForm, Decisions::EvidenceDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Evidence::UploadForm
  describe 'additional CRUD actions' do
    let(:existing_case) { CrimeApplication.create }
    let(:bundle) { DocumentBundle.create(crime_application: existing_case) }

    context 'finishing uploading' do
      it 'has the expected step name' do
        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, record: bundle, as: :upload_finished, flash: nil
        )

        put :update, params: { id: existing_case, record: bundle }
      end
    end
  end
end
