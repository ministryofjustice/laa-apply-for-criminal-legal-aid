require 'rails_helper'

RSpec.describe ProviderDataApi::HttpClient do
  describe '.call' do
    subject(:connection) { described_class.call }

    let(:middleware) { connection.builder.handlers.map(&:klass) }

    it { is_expected.to be_a Faraday::Connection }

    it 'sets the authorisation header' do
      expect(connection.headers['X-Authorization']).to eq 'TestPDASecret'
    end

    it 'uses the configured PDA host url' do
      allow(Faraday).to receive(:new) { double }
      connection
      expect(Faraday).to have_received(:new).with('https://pda.example.com')
    end
  end
end
