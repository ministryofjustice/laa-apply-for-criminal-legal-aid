require 'rails_helper'

RSpec.describe Datastore::Events::DraftDeleted do
  subject {
    described_class.new(entity_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a', entity_type: 'initial',
                        business_reference: '7000001', reason: 'retention_rule', deleted_by: '1')
  }

  let(:endpoint) { 'http://datastore-webmock/api/v1/applications/draft_deleted' }

  before do
    stub_request(:post, endpoint).to_return(body: 'true')
  end

  describe '#call' do
    it 'archives the application' do
      expect(subject.call).to be(true)
    end
  end
end
