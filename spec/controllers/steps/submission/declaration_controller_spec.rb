require 'rails_helper'

RSpec.describe Steps::Submission::DeclarationController, type: :controller do
  include_context 'current provider with active office'

  let(:form_class) { Steps::Submission::DeclarationForm }
  let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
  let(:provider) { current_provider }

  let(:submission_validator) do
    instance_double(SectionsCompletenessValidator, validate: true)
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
      let(:existing_case) {
        CrimeApplication.create(office_code: office_code, applicant: Applicant.new(date_of_birth: '2000-10-10'),
**legal_rep_attrs)
      }

      context 'when it has been reviewed' do
        before do
          allow(SectionsCompletenessValidator).to receive(:new)
            .and_return(submission_validator)
        end

        context 'when application has existing legal rep details' do
          let(:legal_rep_attrs) do
            {
              legal_rep_first_name: 'John',
              legal_rep_last_name: 'Doe',
              legal_rep_telephone: '',
            }
          end

          it 'uses the application details' do
            expect(
              form_class
            ).to receive(:new).with(
              record: provider,
              crime_application: existing_case,
              **legal_rep_attrs
            )

            get :edit, params: { id: existing_case }
            expect(response).to be_successful
          end
        end

        context 'when application has no legal rep details' do
          before do
            allow(provider).to receive_messages(provider_settings)
          end

          let(:legal_rep_attrs) { {} }
          let(:provider_settings) do
            {
              legal_rep_first_name: 'Jane',
              legal_rep_last_name: 'Doe',
              legal_rep_telephone: '999999999',
            }
          end

          it 'uses the provider details' do
            expect(
              form_class
            ).to receive(:new).with(
              record: provider,
              crime_application: existing_case,
              **provider_settings
            )

            get :edit, params: { id: existing_case }
            expect(response).to be_successful
          end
        end
      end

      context 'when the submission has not been reviewed' do
        let(:legal_rep_attrs) { {} }

        it 'redirects to submission/review' do
          get :edit, params: { id: existing_case }

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(edit_steps_submission_review_path)
        end
      end
    end
  end

  describe '#update' do
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) do
      { :id => existing_case, form_class_params_name => { foo: 'bar' } }
    end

    before do
      allow(SectionsCompletenessValidator).to receive(:new).and_return(submission_validator)
    end

    context 'when application is not found' do
      let(:existing_case) { '12345' }

      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when an application in progress is found' do
      let(:existing_case) { CrimeApplication.create(office_code:) }

      before do
        allow(form_class).to receive(:new).and_return(form_object)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save).and_return(true)
        end

        let(:decision_tree) { instance_double(Decisions::SubmissionDecisionTree, destination: '/expected_destination') }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(Decisions::SubmissionDecisionTree).to receive(:new).and_return(decision_tree)

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
          put :update, params: expected_params, session: { crime_application_id: existing_case.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
