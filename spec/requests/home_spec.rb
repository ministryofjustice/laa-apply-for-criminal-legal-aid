require 'rails_helper'

RSpec.describe 'Home' do
  describe 'index' do
    it 'renders the expected page' do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  # Basic smoke test
  describe 'customisation of header and phase tag' do
    context 'for `test` env name' do
      before do
        get root_path
      end

      it 'has the correct body css classes' do
        assert_select 'body.app-body.app-body--test'
      end

      it 'has the correct phase tag' do
        assert_select 'body.app-body.app-body--test' do
          assert_select '.govuk-phase-banner__content__tag', 'test'
        end
      end
    end

    context 'for `production` env name' do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(ENV).to receive(:fetch).with('ENV_NAME').and_return('production')

        get root_path
      end

      it 'has the correct body css classes' do
        assert_select 'body.app-body.app-body--production'
      end

      it 'has the correct phase tag' do
        assert_select 'body.app-body.app-body--production' do
          assert_select '.govuk-phase-banner__content__tag', 'alpha'
        end
      end
    end
  end
end
