require 'rails_helper'

RSpec.describe Steps::Provider::ConfirmOfficeController, type: :controller do
  describe '#edit' do
    it 'responds with HTTP success' do
      get :edit
      expect(response).to be_successful
    end
  end

  describe '#update' do
    let(:form_class) { Steps::Provider::ConfirmOfficeForm }
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { { form_class_params_name => { foo: 'bar' } } }

    before do
      allow(form_class).to receive(:new).and_return(form_object)
    end

    context 'when the form saves successfully' do
      before do
        expect(form_object).to receive(:save).and_return(true)
      end

      let(:decision_tree) do
        instance_double(Decisions::ProviderDecisionTree, destination: '/expected_destination')
      end

      it 'asks the decision tree for the next destination and redirects there' do
        expect(Decisions::ProviderDecisionTree).to receive(:new).and_return(decision_tree)

        put :update, params: expected_params

        expect(response).to have_http_status(:redirect)
        expect(subject).to redirect_to('/expected_destination')
      end
    end

    context 'when the form fails to save' do
      before do
        expect(form_object).to receive(:save).and_return(false)
      end

      it 'renders the question page again' do
        put :update, params: expected_params
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
