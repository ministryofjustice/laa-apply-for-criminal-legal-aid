require 'rails_helper'

RSpec.describe Datastore::ListApplications do
  subject { described_class.new(filtering:, sorting:, pagination:) }

  let(:filtering) do
    { status: 'submitted', office_code: 'XYZ' }
  end

  let(:sorting) do
    { sort_by: 'submitted_at', sort_direction: 'desc' }
  end

  let(:pagination) do
    { page: 1, per_page: 1 }
  end

  let(:expected_query) do
    {
      'status' => 'submitted',
      'office_code' => 'XYZ',
      'sort_by' => 'submitted_at',
      'sort_direction' => 'desc',
      'per_page' => 1,
      'page' => 1,
    }
  end

  let(:datastore_result) do
    '{"pagination":{"total_count":5},"records":[]}'
  end

  before do
    stub_request(:get, 'http://datastore-webmock/api/v1/applications')
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
      stub_request(:get, 'http://datastore-webmock/api/v1/applications')
        .with(query: expected_query)
        .to_raise(StandardError)
    end

    it 'reports the exception, and returns nil' do
      expect(Rails.error).to receive(:report).with(
        an_instance_of(StandardError), hash_including(handled: true)
      )

      expect(subject.call).to be_nil
    end
  end
end
