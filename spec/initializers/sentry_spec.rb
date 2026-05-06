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
        send_default_pii: false,
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
