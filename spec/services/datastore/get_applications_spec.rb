require 'rails_helper'

RSpec.describe Datastore::GetApplications do
  subject { described_class.new(status:, office_code:, per_page:, page:, sort:) }

  let(:status) { 'submitted' }
  let(:office_code) { 'XYZ' }
  let(:per_page) { 1 }
  let(:page) { 1 }
  let(:sort) { 'asc' }

  let(:expected_query) do
    { 'status' => status, 'office_code' => office_code, 'per_page' => per_page, 'page' => page, 'sort' => 'ascending' }
  end

  let(:datastore_result) do
    '{"pagination":{"total_count":5},"records":[]}'
  end

  before do
    stub_request(:get, 'http://datastore-webmock/api/v2/applications')
      .with(query: expected_query)
      .to_return(body: datastore_result)
  end

  describe '#call' do
    it 'returns a Kaminari paginated array' do
      expect(subject.call).to be_a(Kaminari::PaginatableArray)
    end
  end

  context 'handling of errors' do
    before do
      stub_request(:get, 'http://datastore-webmock/api/v2/applications')
        .with(query: expected_query)
        .to_raise(StandardError)

      allow(Sentry).to receive(:capture_exception)
    end

    it 'reports the exception, and returns nil' do
      expect(subject.call).to be_nil

      expect(Sentry).to have_received(:capture_exception).with(
        an_instance_of(StandardError)
      )
    end
  end
end
