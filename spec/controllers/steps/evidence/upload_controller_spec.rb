require 'rails_helper'

RSpec.describe Steps::Evidence::UploadController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Evidence::UploadForm, Decisions::EvidenceDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Evidence::UploadForm

  include_context('with an existing document')

  describe 'additional CRUD actions' do
    before do
      document.save!
    end

    context 'deleting a document' do
      let(:provider) { Provider.new }

      before do
        allow(controller).to receive(:current_provider).and_return(provider)
      end

      it 'has the expected step name' do
        allow_any_instance_of(Datastore::Documents::Delete).to receive(:call).and_return(true)

        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, as: :delete_document,
          flash: { success: 'You deleted test.pdf' }
        )

        expect { put :update, params: { id: crime_application, document_id: document } }
          .to change { crime_application.reload.documents.size }.from(1).to(0)
      end

      it 'is has the correct flash message when delete is unsuccessful' do
        allow_any_instance_of(Datastore::Documents::Delete).to receive(:call).and_return(false)

        expect(
          subject
        ).to receive(:update_and_advance).with(
          Steps::Evidence::UploadForm, as: :delete_document,
          flash: { alert: 'test.pdf could not be deleted – try again' }
        )

        expect { put :update, params: { id: crime_application, document_id: document } }
          .to(not_change { crime_application.reload.documents.size })
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
