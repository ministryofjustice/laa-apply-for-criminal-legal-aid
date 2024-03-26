require 'rails_helper'

RSpec.describe Steps::Capital::AnswersController, type: :controller do
  let(:form_class) { Steps::Capital::AnswersForm }
  let(:decision_tree_class) { Decisions::CapitalDecisionTree }
  let(:crime_application) { CrimeApplication.create! }
  let(:has_no_other_assets) { has_no_other_assets }

  before do
    Capital.create!(crime_application:)
  end

  describe '#edit' do
    context 'when property is found' do
      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:expected_params) do
      {
        id: crime_application,
        steps_capital_answers_form: { has_no_other_assets: }
      }
    end

    context 'when valid capital attributes' do
      let(:has_no_other_assets) { 'yes' }

      it 'redirects to `evidence upload` page' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).to redirect_to(%r{/steps/evidence/upload})
      end
    end

    context 'when invalid capital attributes' do
      context 'when `yes`' do
        let(:has_no_other_assets) { 'no' }

        it 'not redirects to the `evidence upload` path' do
          put :update, params: expected_params, session: { crime_application_id: crime_application.id }
          expect(response).not_to redirect_to(%r{/steps/evidence/upload})
        end
      end

      context 'when `nil`' do
        let(:has_no_other_assets) { nil }

        it 'not redirects to the `evidence upload` path' do
          put :update, params: expected_params, session: { crime_application_id: crime_application.id }
          expect(response).not_to redirect_to(%r{/steps/evidence/upload})
        end
      end
    end
  end
end
