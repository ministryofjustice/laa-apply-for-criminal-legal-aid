require 'rails_helper'

RSpec.describe 'Sentry before_send callback' do # rubocop:disable RSpec/DescribeClass
  subject(:result) { Sentry.configuration.before_send.call(event, {}) }

  let(:event) do
    Sentry::ErrorEvent.new(configuration: Sentry.configuration).tap do |e|
      e.user = { 'email' => 'user@example.com', 'first_name' => 'John', 'id' => 'safe-id' }
    end
  end

  it 'returns a Sentry::ErrorEvent' do
    expect(result).to be_a(Sentry::ErrorEvent)
  end

  describe 'SDK data collection' do
    let(:data_collection) { Sentry.configuration.data_collection }

    it 'does not collect user information, cookies, bodies, or query parameters' do
      expect(data_collection.user_info).to be(false)
      expect(data_collection.cookies.mode).to eq(:off)
      expect(data_collection.http_bodies).to be_empty
      expect(data_collection.url_query_params.mode).to eq(:off)
    end

    it 'does not collect GraphQL, database, or queue data' do
      expect(data_collection.graphql.document).to be(false)
      expect(data_collection.graphql.variables).to be(false)
      expect(data_collection.database_query_data).to be(false)
      expect(data_collection.queues).to be(false)
      expect(data_collection.stack_frame_variables.mode).to eq(:off)
    end

    it 'filters PII-related request and response headers' do
      expect(data_collection.http_headers.request.mode).to eq(:deny_list)
      expect(data_collection.http_headers.request.terms).to eq(Sentry::DataCollection::PII_HEADER_SNIPPETS)
      expect(data_collection.http_headers.response.mode).to eq(:deny_list)
      expect(data_collection.http_headers.response.terms).to eq(Sentry::DataCollection::PII_HEADER_SNIPPETS)
    end
  end

  describe 'user field filtering' do
    it 'filters sensitive user fields' do
      expect(result.user['email']).to eq('[FILTERED]')
      expect(result.user['first_name']).to eq('[FILTERED]')
    end

    it 'preserves non-sensitive user fields' do
      expect(result.user['id']).to eq('safe-id')
    end
  end

  describe 'request data filtering' do
    let(:request_interface) do
      Sentry::RequestInterface.new(
        env: Rack::MockRequest.env_for('/test'),
        data_collection: Sentry.configuration.data_collection,
        rack_env_whitelist: Sentry.configuration.rack_env_whitelist
      ).tap do |r|
        r.data    = { 'nino' => 'AB123456C', 'action' => 'submit' }
        r.cookies = { 'token' => 'abc123', '_ga' => 'safe-ga-value' }
      end
    end

    before { allow(event).to receive(:request).and_return(request_interface) }

    it 'filters sensitive fields in request data' do
      expect(result.request.data['nino']).to eq('[FILTERED]')
    end

    it 'preserves non-sensitive fields in request data' do
      expect(result.request.data['action']).to eq('submit')
    end

    it 'filters sensitive fields in cookies' do
      expect(result.request.cookies['token']).to eq('[FILTERED]')
    end

    it 'preserves non-sensitive cookie values' do
      expect(result.request.cookies['_ga']).to eq('safe-ga-value')
    end
  end
end
