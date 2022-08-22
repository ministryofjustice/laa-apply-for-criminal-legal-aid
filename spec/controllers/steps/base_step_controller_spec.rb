require 'rails_helper'

class DummyStepController < Steps::BaseStepController
  def show
    head(:ok)
  end
end

RSpec.describe DummyStepController, type: :controller do
  before do
    Rails.application.routes.draw do
      get '/dummy_step/:id' => 'dummy_step#show'
      root to: 'dummy_root#index'
    end
  end

  after do
    Rails.application.reload_routes!
  end

  describe 'navigation stack' do
    let!(:crime_application) { CrimeApplication.create }
    let(:dummy_step_path) { "/dummy_step/#{crime_application.to_param}" }

    before do
      crime_application.update(
        navigation_stack: navigation_stack
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
      let(:navigation_stack) { %w(/foo /bar /baz) }

      it 'adds it to the end of the stack' do
        expect(crime_application.navigation_stack).to eq(navigation_stack + [dummy_step_path])
      end
    end
  end

  describe '#previous_step_path' do
    let!(:crime_application) { CrimeApplication.create(navigation_stack: navigation_stack) }

    before do
      get :show, params: { id: crime_application }
    end

    context 'when the stack is empty' do
      let(:navigation_stack) { [] }

      it 'returns the root path' do
        expect(subject.previous_step_path).to eq('/')
      end
    end

    context 'when the stack has elements' do
      let(:navigation_stack) { %w(/somewhere /over /the /rainbow) }

      it 'returns the element before the current page' do
        # Not '/the', as we've performed a page load and thus added '/dummy_page' at the end
        expect(subject.previous_step_path).to eq('/rainbow')
      end
    end
  end
end
