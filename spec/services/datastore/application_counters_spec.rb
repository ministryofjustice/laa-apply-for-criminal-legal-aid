require 'rails_helper'

RSpec.describe Datastore::ApplicationCounters do
  subject { described_class.new }

  let(:datastore_result) do
    '{"pagination":{"total_count":5},"records":[]}'
  end

  before do
    stub_request(:get, 'http://datastore-webmock/api/v2/applications')
      .with(query: { 'status' => status, 'per_page' => 1 })
      .to_return(body: datastore_result)
  end

  describe '#returned_count' do
    let(:status) { 'returned' }

    it 'returns total returned applications' do
      expect(subject.returned_count).to eq(5)
    end
  end

  context 'handling of errors' do
    let(:status) { 'returned' }

    before do
      stub_request(:get, 'http://datastore-webmock/api/v2/applications')
        .with(query: { 'status' => status, 'per_page' => 1 })
        .to_raise(StandardError)

      allow(Sentry).to receive(:capture_exception)
    end

    it 'reports the exception, and returns 0 count' do
      expect(subject.returned_count).to eq(0)

      expect(Sentry).to have_received(:capture_exception).with(
        an_instance_of(StandardError)
      )
    end
  end
end
