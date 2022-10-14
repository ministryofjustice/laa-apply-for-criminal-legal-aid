require 'rails_helper'

RSpec.describe Steps::Case::IojController, type: :controller do
  let(:form_class) { Steps::Case::IojForm }
  let(:decision_tree_class) { Decisions::CaseDecisionTree }

  let(:crime_application) { CrimeApplication.create }

  describe '#update' do
    let(:form_class_params_name) { form_class.name.underscore }
    let(:existing_case) { Case.create(crime_application:) }
    let(:ioj_record) { Ioj.create(case: existing_case) }

    context 'when adding an ioj' do
      let(:ioj_attributes) do
        {
          'types' => ['reputation'],
          'expert_examination_justification' => nil,
           'interest_of_another_justification' => nil,
           'loss_of_liberty_justification' => nil,
          'loss_of_livelyhood_justification' => nil,
          'other_justification' => nil,
          'question_of_law_justification' => nil,
          'reputation_justification' => 'A justification',
          'suspended_sentence_justification' => nil,
          'understanding_justification' => nil,
          'witness_tracing_justification' => nil
        }
      end

      after do
        put :update, params: {
          :id => crime_application.id,
          form_class_params_name => ioj_attributes
        }
      end

      it 'has the expected step name' do
        expect(
          subject
        ).to receive(:update_and_advance).with(
          form_class,
          record: ioj_record,
          as: :ioj
        )
      end
    end
  end

  describe '#edit' do
    context 'when application is not found' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let!(:existing_application) { CrimeApplication.create(case: Case.new) }

      it 'responds with HTTP success' do
        get :edit, params: { id: existing_application }
        expect(response).to be_successful
      end
    end
  end
end
