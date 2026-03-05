require 'rails_helper'

RSpec.describe Govuk::BankHolidays do
  let(:api_url) { ENV.fetch('BANK_HOLIDAYS_API_URL', nil) }

  let(:england_wales_events) do
    [
      { 'title' => "New Year's Day", 'date' => '2026-01-01', 'notes' => '', 'bunting' => true },
      { 'title' => 'Good Friday',    'date' => '2026-04-03', 'notes' => '', 'bunting' => false },
      { 'title' => 'Easter Monday',  'date' => '2026-04-06', 'notes' => '', 'bunting' => true },
    ]
  end

  let(:scotland_events) do
    [
      { 'title' => "New Year's Day", 'date' => '2026-01-01', 'notes' => '', 'bunting' => true },
      { 'title' => '2nd January',    'date' => '2026-01-02', 'notes' => '', 'bunting' => true },
    ]
  end

  let(:api_response_body) do
    {
      'england-and-wales' => { 'division' => 'england-and-wales', 'events' => england_wales_events },
      'scotland'          => { 'division' => 'scotland',          'events' => scotland_events },
      'northern-ireland'  => { 'division' => 'northern-ireland',  'events' => [] },
    }.to_json
  end

  before do
    stub_request(:get, api_url)
      .to_return(status: 200, body: api_response_body,
                 headers: { 'Content-Type' => 'application/json' })
  end

  describe '#call' do
    subject(:service) { described_class.new }

    describe 'DEFAULT_REGION constant' do
      it 'is england-and-wales' do
        expect(described_class::DEFAULT_REGION).to eq 'england-and-wales'
      end
    end

    context 'with the default region' do
      it 'returns an array of Date objects' do
        expect(service.call).to all(be_a(Date))
      end

      it 'returns the correct dates' do
        expect(service.call).to eq [
          Date.new(2026, 1, 1),
          Date.new(2026, 4, 3),
          Date.new(2026, 4, 6),
        ]
      end
    end

    context 'with a custom region (scotland)' do
      it 'returns dates only for that region' do
        expect(service.call('scotland')).to eq [
          Date.new(2026, 1, 1),
          Date.new(2026, 1, 2),
        ]
      end
    end

    context 'with a region that has no events' do
      it 'returns an empty array' do
        expect(service.call('northern-ireland')).to eq []
      end
    end

    context 'when the API response body is blank' do
      before do
        allow(Rails.cache).to receive(:fetch).and_return(nil)
      end

      it 'returns nil' do
        expect(service.call).to be_nil
      end
    end

    context 'caching behaviour' do
      it 'stores the result under the bank-holidays cache key with a 3-month expiry' do
        expect(Rails.cache).to receive(:fetch)
          .with('bank-holidays', expires_in: 3.months)
          .and_call_original

        service.call
      end

      it 'only fetches from the remote API once per instance' do
        service.call
        service.call

        expect(a_request(:get, api_url)).to have_been_made.once
      end
    end

    context 'when the API returns a server error' do
      before do
        stub_request(:get, api_url).to_return(status: 500)
      end

      it 'raises a Faraday::ServerError' do
        expect { service.call }.to raise_error(Faraday::ServerError)
      end
    end
  end
end
