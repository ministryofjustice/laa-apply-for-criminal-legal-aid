require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def invalid_session; raise Errors::InvalidSession; end
    def application_not_found; raise Errors::ApplicationNotFound; end
    def another_exception; raise Exception; end
  end

  context 'Exceptions handling' do
    context 'Errors::InvalidSession' do
      it 'should not report the exception, and redirect to the error page' do
        routes.draw { get 'invalid_session' => 'anonymous#invalid_session' }

        expect(Sentry).not_to receive(:capture_exception)

        get :invalid_session
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    context 'Errors::ApplicationNotFound' do
      it 'should not report the exception, and redirect to the error page' do
        routes.draw { get 'application_not_found' => 'anonymous#application_not_found' }

        expect(Sentry).not_to receive(:capture_exception)

        get :application_not_found
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'Other exceptions' do
      before do
        allow(Rails.application.config).to receive(:consider_all_requests_local).and_return(false)
      end

      it 'should report the exception, and redirect to the error page' do
        routes.draw { get 'another_exception' => 'anonymous#another_exception' }

        expect(Sentry).to receive(:capture_exception)

        get :another_exception
        expect(response).to redirect_to(unhandled_errors_path)
      end
    end
  end
end
