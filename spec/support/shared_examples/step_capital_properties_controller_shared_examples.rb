RSpec.shared_examples 'capital properties controller' do |parameter|
  let(:property_type) { parameter }
  let(:form_class) { "Steps::Capital::#{property_type.titleize}Form".constantize }
  let(:decision_tree_class) { Decisions::CapitalDecisionTree }

  let(:crime_application) { CrimeApplication.create }

  describe '#edit' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', property_id: '123' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:property) do
        Property.create!(property_type:, crime_application:)
      end

      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, property_id: property }
        expect(response).to be_successful
      end
    end

    context 'when property is for another application' do
      let(:property) do
        Property.create!(property_type: property_type, crime_application: CrimeApplication.create!)
      end

      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, property_id: property }

        expect(response).to redirect_to(not_found_errors_path)
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }

    let(:expected_params) do
      {
        :id => crime_application,
        :property_id => property,
        form_class_params_name => { foo: 'bar' }
      }
    end

    context 'when application is not found' do
      let(:crime_application) { '12345' }
      let(:property) { '123' }

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when property is for another application' do
      let(:property) do
        Property.create!(property_type: property_type, crime_application: CrimeApplication.create!)
      end

      it 'responds with HTTP success' do
        put :update, params: expected_params

        expect(response).to redirect_to(not_found_errors_path)
      end
    end

    context 'when an in progress application and property is found' do
      let(:property) do
        Property.create!(property_type:, crime_application:)
      end

      before do
        property
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

        it 'renders the property page again' do
          put :update, params: expected_params, session: { crime_application_id: crime_application.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe '#destroy' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }

    let(:expected_params) do
      {
        :id => crime_application,
        :property_id => property,
        form_class_params_name => { foo: 'bar' }
      }
    end

    context 'when deleting an asset' do
      let(:property) do
        Property.create!(property_type:, crime_application:)
      end

      describe 'confirm destroy' do
        it 'renders the property page again' do
          get :confirm_destroy, params: expected_params, session: { crime_application_id: crime_application.id }
          expect(response).not_to have_http_status(:redirect)
        end
      end

      context 'when deleting an asset' do
        context 'when asset the last remaining asset' do
          it 'renders the property page again' do
            delete :destroy, params: expected_params, session: { crime_application_id: crime_application.id }
            expect(Property.count).to be 0
            expect(response).to redirect_to(%r{/steps/capital/which-assets-owned})
          end
        end

        context 'when not the last remaining asset' do
          before do
            Property.create!(property_type:, crime_application:)
          end

          it 'renders the property page again' do
            delete :destroy, params: expected_params, session: { crime_application_id: crime_application.id }
            expect(Property.count).to be 1
            expect(response).to redirect_to edit_steps_capital_properties_summary_path
          end
        end
      end
    end
  end
end
