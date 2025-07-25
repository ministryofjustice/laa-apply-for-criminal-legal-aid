require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def invalid_token = raise(ActionController::InvalidAuthenticityToken)
    def invalid_session = raise(Errors::InvalidSession)
    def application_not_found = raise(Errors::ApplicationNotFound)
    def another_exception = raise(StandardError)
    def missing_translation = [I18n.t("cy.missing_key"), I18n.t("en.missing_key")]
  end

  context 'Exceptions handling' do
    context 'ActionController::InvalidAuthenticityToken' do
      it 'does not report the exception, and redirects to the error page' do
        routes.draw { get 'invalid_token' => 'anonymous#invalid_token' }

        expect(Rails.error).not_to receive(:report)

        get :invalid_token
        expect(response).to redirect_to(invalid_token_errors_path)
      end
    end

    context 'Errors::InvalidSession' do
      it 'does not report the exception, and redirect to the error page' do
        routes.draw { get 'invalid_session' => 'anonymous#invalid_session' }

        expect(Rails.error).not_to receive(:report)

        get :invalid_session
        expect(response).to redirect_to(invalid_session_errors_path)
      end
    end

    context 'Errors::ApplicationNotFound' do
      it 'does not report the exception, and redirect to the error page' do
        routes.draw { get 'application_not_found' => 'anonymous#application_not_found' }

        expect(Rails.error).not_to receive(:report)

        get :application_not_found
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'I18n::MissingTranslationData' do
      it 'raises an exception when locale is missing' do
        routes.draw { get 'missing_translation' => 'anonymous#missing_translation' }
        
        expect {
          get :missing_translation
        }.to raise_error(I18n::MissingTranslationData)
      end
    end

    context 'Other exceptions' do
      before do
        allow(Rails.application.config).to receive(:consider_all_requests_local).and_return(false)
      end

      it 'reports the exception, and redirect to the error page' do
        routes.draw { get 'another_exception' => 'anonymous#another_exception' }

        expect(Rails.error).to receive(:report).with(
          an_instance_of(StandardError), hash_including(handled: false)
        ).and_call_original

        expect(Rails.logger).to receive(:error)

        get :another_exception
        expect(response).to redirect_to(unhandled_errors_path)
      end
    end
  end
end
