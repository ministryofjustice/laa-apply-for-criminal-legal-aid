require 'rails_helper'

RSpec.describe Steps::Evidence::UploadController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Evidence::UploadForm, Decisions::EvidenceDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Evidence::UploadForm
  describe 'additional CRUD actions' do
    include_context 'with an existing document'

    context 'deleting a document' do
      it 'has the expected step name' do
        document.save

        allow_any_instance_of(Datastore::Documents::Delete).to receive(:call).and_return(true)

        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, as: :delete_document,
          flash: { success: 'Document has been sucessfully deleted' },
          record: document.document_bundle
        )

        put :update, params: { id: bundle.crime_application, document_id: document.id }
      end

      it 'is has the correct flash message when delete is unsuccessful' do
        document.save

        allow_any_instance_of(Datastore::Documents::Delete).to receive(:call).and_return(false)

        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, as: :delete_document,
          flash: { alert: 'Document was not sucessfully deleted' },
          record: document.document_bundle
        )

        put :update, params: { id: bundle.crime_application, document_id: document.id }
      end
    end

    context 'finishing uploading' do
      it 'has the expected step name' do
        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, record: bundle, as: :upload_finished, flash: nil
        )

        put :update, params: { id: bundle.crime_application, record: bundle }
      end
    end
  end
end
