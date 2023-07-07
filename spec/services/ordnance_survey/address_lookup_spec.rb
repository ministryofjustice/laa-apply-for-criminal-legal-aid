require 'rails_helper'

RSpec.describe OrdnanceSurvey::AddressLookup do
  subject(:service) { described_class.new(postcode) }

  let(:query_params) do
    {
      key: 'test-token',
      postcode: postcode,
      lr: 'EN',
    }
  end

  let(:api_request_uri) do
    uri = URI.parse(described_class::ORDNANCE_SURVEY_URL)
    uri.query = query_params.to_query
    uri
  end

  let(:postcode) { 'SW1H9AJ' }

  describe '#result' do
    before do
      allow(ENV).to receive(:fetch) # any other fetches, like Faraday `http_proxy`
      allow(ENV).to receive(:fetch).with('ORDNANCE_SURVEY_API_KEY').and_return('test-token')
    end

    context 'when the lookup is successful' do
      let(:stubbed_json_body) { file_fixture('address_lookups/success.json') }

      before do
        stub_request(:get, api_request_uri)
          .to_return(status: 200, body: stubbed_json_body)
        service.call
      end

      it 'returns the collection of addresses' do
        expect(service).to be_success
        expect(service.call).to all(be_an(OrdnanceSurvey::AddressLookupResults::Address))
        expect(service.call.size).to eq(1)
      end

      context 'but the response does not contain any results' do
        let(:stubbed_json_body) { file_fixture('address_lookups/no_results.json') }

        it 'has a successful outcome' do
          expect(service).to be_success
          expect(service.call).to eq([])
        end
      end

      context 'the response cannot be parsed (`header` not found)' do
        let(:stubbed_json_body) { '{"unknown":"keys"}' }

        it 'has an unsuccessful outcome' do
          expect(service).not_to be_success
          expect(service.call).to eq([])
          expect(service.last_exception).to be_a(KeyError)
        end
      end

      context 'the response cannot be parsed (`totalresults` not found)' do
        let(:stubbed_json_body) { '{"header":{"foo":"bar"}}' }

        it 'has an unsuccessful outcome' do
          expect(service).not_to be_success
          expect(service.call).to eq([])
          expect(service.last_exception).to be_a(KeyError)
        end
      end

      context 'the response cannot be parsed (invalid json)' do
        let(:stubbed_json_body) { 'not_json' }

        it 'has an unsuccessful outcome' do
          expect(service).not_to be_success
          expect(service.call).to eq([])
          expect(service.last_exception).to be_a(JSON::ParserError)
        end
      end
    end

    context 'when there is a problem connecting to the postcode API' do
      before do
        stub_request(:get, api_request_uri)
          .to_raise(Errno::ECONNREFUSED)
        service.call
      end

      it 'has an unsuccessful outcome' do
        expect(service).not_to be_success
        expect(service.call).to eq([])
        expect(service.last_exception).to be_a(Faraday::ConnectionFailed)
      end
    end

    context 'when the request payload is not correct' do
      let(:stubbed_body) do
        {
          error: {
            statuscode: 400,
            message: 'Parameter postcode cannot be empty.'
          }
        }
      end

      before do
        stub_request(:get, api_request_uri)
          .to_return(status: 400, body: stubbed_body.to_json)
        service.call
      end

      it 'has an unsuccessful outcome' do
        expect(service).not_to be_success
        expect(service.call).to eq([])
        expect(service.last_exception).to be_a(OrdnanceSurvey::AddressLookup::UnsuccessfulLookupError)
        expect(service.last_exception.message).to eq(
          '{"error":{"statuscode":400,"message":"Parameter postcode cannot be empty."}}'
        )
      end
    end

    context 'capturing and reporting errors' do
      let(:exception) { StandardError.new('boom!') }

      before do
        stub_request(:get, api_request_uri)
          .to_raise(exception)
      end

      it 'reports the error' do
        expect(Rails.error).to receive(:report).with(
          exception, hash_including(handled: true)
        )

        service.call
      end

      it 'stores the last exception' do
        service.call
        expect(service.last_exception).not_to be_nil
      end

      it 'returns an empty array' do
        expect(service.call).to eq([])
      end
    end
  end
end
