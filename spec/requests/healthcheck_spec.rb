require 'rails_helper'

RSpec.describe 'Healthcheck endpoint' do
  let(:error_response)   { '{"healthcheck":"NOT OK"}' }
  let(:success_response) { '{"healthcheck":"OK"}' }

  describe '/health' do
    context 'when database and virus scan are healthy' do
      it 'reports a success' do
        allow(ActiveRecord::Base.connection).to receive(:active?)
          .and_return(true)

        allow(Clamby).to receive(:safe?).and_return(true)

        get '/health'
        expect(response.body).to eq(success_response)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when database is unhealthy and virus scan is healthy' do
      it 'reports a failure' do
        allow(ActiveRecord::Base.connection).to receive(:execute)
          .and_raise(StandardError)

        allow(Clamby).to receive(:safe?).and_return(true)

        get '/health'
        expect(response.body).to eq(error_response)
        expect(response).to have_http_status(:service_unavailable)
      end
    end

    context 'when database is healthy and virus scan is unhealthy' do
      it 'reports a failure' do
        allow(ActiveRecord::Base.connection).to receive(:active?)
          .and_return(true)

        allow(Clamby).to receive(:safe?).and_raise(Clamby::ClamscanClientError)

        get '/health'
        expect(response.body).to eq(success_response)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe '/readyz' do
    subject(:readyz_response) { response }

    context 'when database and virus scan are healthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?)
          .and_return(true)

        allow(Clamby).to receive(:safe?).and_return(true)

        get '/readyz'
      end

      it { is_expected.to have_http_status :ok }
    end

    context 'when database is unhealthy and virus scan is healthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute)
          .and_raise(StandardError)

        allow(Clamby).to receive(:safe?).and_return(true)

        get '/readyz'
      end

      it { is_expected.to have_http_status :service_unavailable }
    end

    context 'when database is healthy and virus scan is unhealthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?)
          .and_return(true)

        allow(Clamby).to receive(:safe?).and_raise(Clamby::ClamscanClientError)

        get '/readyz'
      end

      it { is_expected.to have_http_status :ok }
    end
  end

  describe '/startupz' do
    subject(:startupz_response) { response }

    context 'when database and virus scan are healthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?)
          .and_return(true)

        allow(Clamby).to receive(:safe?).and_return(true)

        get '/startupz'
      end

      it { is_expected.to have_http_status :ok }
    end

    context 'when database is unhealthy and virus scan is healthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute)
          .and_raise(StandardError)

        allow(Clamby).to receive(:safe?).and_return(true)

        get '/startupz'
      end

      it { is_expected.to have_http_status :service_unavailable }
    end

    context 'when database is healthy and virus scan is unhealthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?)
          .and_return(true)

        allow(Clamby).to receive(:safe?).and_raise(Clamby::ClamscanClientError)

        get '/startupz'
      end

      it { is_expected.to have_http_status :service_unavailable }
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
