require 'rails_helper'

RSpec.shared_examples 'a show step controller' do
  describe '#show' do
    context 'when no case exists in the session' do
      it 'redirects to the invalid session error page' do
        get :show
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    context 'when a case exists in the session' do
      let(:existing_case) { CrimeApplication.create }

      it 'responds with HTTP success' do
        get :show, session: { crime_application_id: existing_case.id }
        expect(response).to be_successful
      end
    end
  end
end

RSpec.shared_examples 'a generic step controller' do |form_class, decision_tree_class|
  describe '#edit' do
    context 'when no case exists in the session yet' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the invalid session error page' do
        get :edit
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    # NOTE: for now it is ok to assume we just have the applicant, but when we
    # integrate the partner steps, this will have to either be passed as configuration
    # to the shared examples, or to also create the partner associated record.
    #
    context 'when a case exists in the session' do
      let!(:existing_case) { CrimeApplication.create(applicant: Applicant.new) }

      it 'responds with HTTP success' do
        get :edit, session: { crime_application_id: existing_case.id }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { { form_class_params_name => { foo: 'bar' } } }

    context 'when there is no case in the session' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the invalid session error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    context 'when a case in progress is in the session' do
      let(:existing_case) { CrimeApplication.create }

      before do
        allow(form_class).to receive(:new).and_return(form_object)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save).and_return(true)
        end

        let(:decision_tree) { instance_double(decision_tree_class, destination: '/expected_destination') }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(decision_tree_class).to receive(:new).and_return(decision_tree)
          put :update, params: expected_params, session: { crime_application_id: existing_case.id }
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

RSpec.shared_examples 'an address step controller' do |form_class, decision_tree_class|
  describe '#edit' do
    context 'when no case exists in the session yet' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the invalid session error page' do
        get :edit
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    context 'when a case exists in the session' do
      let!(:existing_case) { CrimeApplication.create(applicant: Applicant.new) }
      let!(:existing_address) { HomeAddress.find_or_create_by(person: existing_case.applicant) }

      it 'responds with HTTP success' do
        get :edit, params: { id: existing_address.id }, session: { crime_application_id: existing_case.id }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }

    context 'when there is no case in the session' do
      let(:expected_params) { { id: '1234', form_class_params_name => { foo: 'bar' } } }

      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the invalid session error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    context 'when a case in progress is in the session' do
      let!(:existing_case) { CrimeApplication.create(applicant: Applicant.new) }
      let!(:existing_address) { HomeAddress.find_or_create_by(person: existing_case.applicant) }

      let(:expected_params) { { id: existing_address.id, form_class_params_name => { foo: 'bar' } } }

      before do
        allow(form_class).to receive(:new).and_return(form_object)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save).and_return(true)
        end

        let(:decision_tree) { instance_double(decision_tree_class, destination: '/expected_destination') }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(decision_tree_class).to receive(:new).and_return(decision_tree)

          put :update, params: expected_params, session: { crime_application_id: existing_case.id }

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

RSpec.shared_examples 'a starting point step controller' do
  describe '#edit' do
    context 'when no case exists in the session yet' do
      it 'responds with HTTP success' do
        get :edit
        expect(response).to be_successful
      end

      it 'creates a new case' do
        expect { get :edit }.to change { CrimeApplication.count }.by(1)
      end

      it 'sets the case ID in the session' do
        expect(session[:crime_application_id]).to be_nil
        get :edit
        expect(session[:crime_application_id]).not_to be_nil
      end
    end

    context 'when a case exists in the session' do
      let!(:existing_case) { CrimeApplication.create(navigation_stack: %w(/not /empty)) }

      it 'does not create a new case' do
        expect {
          get :edit, session: { crime_application_id: existing_case.id }
        }.to_not change { CrimeApplication.count }
      end

      it 'responds with HTTP success' do
        get :edit, session: { crime_application_id: existing_case.id }
        expect(response).to be_successful
      end

      it 'does not change the case ID in the session' do
        get :edit, session: { crime_application_id: existing_case.id }
        expect(session[:crime_application_id]).to eq(existing_case.id)
      end

      it 'clears the navigation stack in the session' do
        get :edit, session: { crime_application_id: existing_case.id }
        existing_case.reload

        expect(existing_case.navigation_stack).to eq([controller.request.fullpath])
      end
    end
  end
end

RSpec.shared_examples 'a step that can be drafted' do |form_class|
  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { { form_class_params_name => { foo: 'bar' }, commit_draft: '' } }

    context 'when there is no case in the session' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the invalid session error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    context 'when a case in progress is in the session' do
      let(:existing_case) { CrimeApplication.create }

      before do
        allow(form_class).to receive(:new).and_return(form_object)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save!).and_return(true)
        end

        # TODO: This will have to change once we decide where the secondary button goes
        it 'redirects to the root path' do
          put :update, params: expected_params, session: { crime_application_id: existing_case.id }
          expect(subject).to redirect_to(root_path)
        end
      end

      context 'when the form fails to save it does not matter' do
        before do
          expect(form_object).to receive(:save!).and_return(false)
        end

        # TODO: This will have to change once we decide where the secondary button goes
        it 'redirects to the root path' do
          put :update, params: expected_params, session: { crime_application_id: existing_case.id }
          expect(subject).to redirect_to(root_path)
        end
      end
    end
  end
end
