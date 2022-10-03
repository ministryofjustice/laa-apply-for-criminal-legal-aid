require 'rails_helper'

RSpec.describe 'Healthcheck endpoint' do
  let(:error_response)   { '{"healthcheck":"NOT OK"}' }
  let(:success_response) { '{"healthcheck":"OK"}' }

  describe 'healthchecks' do
    it 'can report a success' do
      allow(ActiveRecord::Base.connection).to receive(:active?)
        .and_return(true)

      get '/health'
      expect(response.body).to eq(success_response)
      expect(response).to have_http_status(:ok)
    end

    it 'can report a failure' do
      allow(ActiveRecord::Base.connection).to receive(:active?)
        .and_raise(StandardError)

      get '/health'
      expect(response.body).to eq(error_response)
      expect(response).to have_http_status(:service_unavailable)
    end
  end

  describe 'Ping endpoint' do
    before do
      allow(ENV).to receive(:fetch).with('APP_BUILD_DATE', nil).and_return('date')
      allow(ENV).to receive(:fetch).with('APP_BUILD_TAG',  nil).and_return('tag')
      allow(ENV).to receive(:fetch).with('APP_GIT_COMMIT', nil).and_return('commit')
    end

    it 'has a 200 response code' do
      get '/ping'
      expect(response).to have_http_status(:ok)
    end

    it 'returns the expected payload' do
      get '/ping'
      expect(
        response.body
      ).to eq('{"build_date":"date","build_tag":"tag","commit_id":"commit"}')
    end
  end
end
