require 'rails_helper'

class DummyStepController < Steps::BaseStepController
  def show
    head(:ok)
  end
end

RSpec.describe DummyStepController, type: :controller do
  include_context 'current provider with active office'

  before do
    Rails.application.routes.append do
      get '/dummy_step/:id', to: 'dummy_step#show'
      get '/dummy_step/:id/edit', to: 'dummy_step#edit'
      put '/dummy_step/:id', to: 'dummy_step#update'
    end
    Rails.application.reload_routes!
  end

  describe 'navigation stack' do
    let!(:crime_application) { CrimeApplication.create(office_code:) }
    let(:dummy_step_path) { "/dummy_step/#{crime_application.to_param}" }

    before do
      crime_application.update(
        navigation_stack:
      )

      get :show, params: { id: crime_application }
      crime_application.reload
    end

    context 'when the stack is empty' do
      let(:navigation_stack) { [] }

      it 'adds the page to the stack' do
        expect(crime_application.navigation_stack).to eq([dummy_step_path])
      end
    end

    context 'when the current page is on the stack' do
      let(:navigation_stack) { ['/foo', '/bar', dummy_step_path, '/baz'] }

      it 'rewinds the stack to the appropriate point' do
        expect(crime_application.navigation_stack).to eq(['/foo', '/bar', dummy_step_path])
      end
    end

    context 'when the current page is not on the stack' do
      let(:navigation_stack) { %w[/foo /bar /baz] }

      it 'adds it to the end of the stack' do
        expect(crime_application.navigation_stack).to eq(navigation_stack + [dummy_step_path])
      end
    end
  end
end
