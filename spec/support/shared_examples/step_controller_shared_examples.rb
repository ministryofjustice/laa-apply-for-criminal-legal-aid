require 'rails_helper'

RSpec.shared_examples 'a show step controller' do
  include_context 'current provider with active office'
  let(:base_params) { {} }

  include_context 'current provider with active office'

  describe '#show' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :show, params: base_params.merge(id: '12345')
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:existing_case) { CrimeApplication.create(office_code:) }

      it 'responds with HTTP success' do
        get :show, params: base_params.merge(id: existing_case)
        expect(response).to be_successful
      end
    end
  end
end

RSpec.shared_examples 'a generic step controller' do |form_class, decision_tree_class|
  include_context 'current provider with active office'
  let(:base_params) { {} }

  describe '#edit' do
    context 'when application is not found' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        get :edit, params: base_params.merge(id: '12345')
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    # NOTE: for now it is ok to assume we just have the applicant, but when we
    # integrate the partner steps, this will have to either be passed as configuration
    # to the shared examples, or to also create the partner associated record.
    #
    context 'when application is found' do
      unless method_defined?(:existing_case)
        let(:existing_case) do
          CrimeApplication.create!(
            applicant: Applicant.new,
            partner: Partner.new,
            partner_detail: PartnerDetail.new(involvement_in_case: false),
            office_code: office_code
          )
        end
      end

      it 'responds with HTTP success' do
        get :edit, params: base_params.merge(id: existing_case)
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { base_params.merge(:id => existing_case, form_class_params_name => { foo: 'bar' }) }

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
      let(:existing_case) { CrimeApplication.create!(office_code:) } unless method_defined?(:existing_case)

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
end

RSpec.shared_examples 'a no-op advance step controller' do |step_name, decision_tree_class|
  include_context 'current provider with active office'
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
      let(:existing_case) { CrimeApplication.create(applicant: Applicant.new, office_code: office_code) }

      it 'responds with HTTP success' do
        get :edit, params: { id: existing_case }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_class) { Steps::Shared::NoOpForm }
    let(:form_object) { form_class.new }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { { :id => existing_case, form_class_params_name => {} } }

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

      context 'no-op advance' do
        let(:decision_tree) { instance_double(decision_tree_class, destination: '/expected_destination') }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(
            decision_tree_class
          ).to receive(:new).with(form_object, as: step_name).and_return(decision_tree)

          put :update, params: expected_params

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to('/expected_destination')
        end
      end
    end
  end
end

RSpec.shared_examples 'an address step controller' do |form_class, decision_tree_class|
  include_context 'current provider with active office'
  describe '#edit' do
    context 'when application is not found' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', address_id: '123' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:existing_case) { CrimeApplication.create(applicant: Applicant.new, office_code: office_code) }
      let(:existing_address) { HomeAddress.find_or_create_by(person: existing_case.applicant) }

      it 'responds with HTTP success' do
        get :edit, params: { id: existing_case, address_id: existing_address }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) do
      { :id => existing_case, :address_id => existing_address, form_class_params_name => { foo: 'bar' } }
    end

    context 'when application is not found' do
      let(:existing_case) { '12345' }
      let(:existing_address) { '123' }

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
      let(:existing_case) { CrimeApplication.create(office_code: office_code, applicant: Applicant.new) }
      let(:existing_address) { HomeAddress.find_or_create_by(person: existing_case.applicant) }

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

RSpec.shared_examples 'a step that can be drafted' do |form_class|
  include_context 'current provider with active office'
  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { { :id => existing_case, form_class_params_name => { foo: 'bar' }, :commit_draft => '' } }

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
          expect(form_object).to receive(:save!).and_return(true)
        end

        it 'redirects to the application task list' do
          put :update, params: expected_params
          expect(subject).to redirect_to(edit_crime_application_path(existing_case))
        end
      end

      context 'when the form fails to save it does not matter' do
        before do
          expect(form_object).to receive(:save!).and_return(false)
        end

        it 'redirects to the application task list' do
          put :update, params: expected_params
          expect(subject).to redirect_to(edit_crime_application_path(existing_case))
        end
      end
    end
  end
end

RSpec.shared_examples 'a step disallowed for change in financial circumstances applications' do
  include_context 'current provider with active office'
  let(:existing_case) do
    CrimeApplication.create!(
      application_type: ApplicationType::CHANGE_IN_FINANCIAL_CIRCUMSTANCES,
      office_code: office_code
    )
  end

  describe '#edit' do
    it 'redirects back to the task list because user is not allowed to complete this form' do
      get :edit, params: { id: existing_case.id }

      expect(response).to redirect_to(edit_crime_application_path(existing_case))
    end
  end

  describe '#update' do
    it 'redirects back to the task list because user is not allowed to complete this form' do
      get :update, params: { id: existing_case.id }

      expect(response).to redirect_to(edit_crime_application_path(existing_case))
    end
  end
end

RSpec.shared_examples 'a step disallowed for non change in financial circumstances applications' do
  include_context 'current provider with active office'
  let(:existing_case) do
    CrimeApplication.create!(office_code: office_code, application_type: ApplicationType::INITIAL)
  end

  describe '#edit' do
    it 'redirects back to the task list because user is not allowed to complete this form' do
      get :edit, params: { id: existing_case.id }

      expect(response).to redirect_to(edit_crime_application_path(existing_case))
    end
  end

  describe '#update' do
    it 'redirects back to the task list because user is not allowed to complete this form' do
      get :update, params: { id: existing_case.id }

      expect(response).to redirect_to(edit_crime_application_path(existing_case))
    end
  end
end
