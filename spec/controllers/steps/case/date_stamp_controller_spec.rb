require 'rails_helper'

RSpec.describe Steps::Case::DateStampController, type: :controller do
  describe '#show' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :show, params: { id: '12345' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:crime_application) { CrimeApplication.create }
      let(:existing_case) { Case.create(crime_application:) }

      it 'responds with HTTP redirect' do
        expect(response).to have_http_status(:ok)
      end

      it 'adds an offence' do
        get :show, params: { id: crime_application, case: existing_case }

        expect(Charge.count).to eq(1)
      end
    end
  end
end
