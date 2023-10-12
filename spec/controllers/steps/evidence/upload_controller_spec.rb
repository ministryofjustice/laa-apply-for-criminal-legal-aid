require 'rails_helper'

RSpec.describe Steps::Evidence::UploadController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Evidence::UploadForm, Decisions::EvidenceDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Evidence::UploadForm

  describe 'additional CRUD actions' do
    let(:crime_application) { CrimeApplication.create }
    let(:document) { crime_application.documents.create }

    context 'deleting a document' do
      it 'has the expected step name' do
        allow_any_instance_of(Datastore::Documents::Delete).to receive(:call).and_return(true)

        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, as: :delete_document,
          flash: { success: I18n.t('steps.evidence.upload.edit.delete.success', file_name: document.filename).to_s }
        )

        put :update, params: { id: crime_application, document_id: document }
      end

      it 'is has the correct flash message when delete is unsuccessful' do
        allow_any_instance_of(Datastore::Documents::Delete).to receive(:call).and_return(false)

        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, as: :delete_document,
          flash: { alert: I18n.t('steps.evidence.upload.edit.delete.failure', file_name: document.filename).to_s }
        )

        put :update, params: { id: crime_application, document_id: document }
      end
    end

    context 'finishing uploading' do
      it 'has the expected step name' do
        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, as: :upload_finished, flash: nil
        )

        put :update, params: { id: crime_application }
      end
    end
  end
end
