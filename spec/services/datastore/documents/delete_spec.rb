require 'rails_helper'

RSpec.describe Datastore::Documents::Delete do
  subject { described_class.new(object_key:) }

  include_context 'with an existing document'

  let(:object_key) { '123/abcdef1234' }

  describe '#call' do
    context 'when a document is deleted successfully' do
      before do
        stub_request(:delete, 'http://datastore-webmock/api/v1/documents/MTIzL2FiY2RlZjEyMzQ=')
          .to_return(status: 200, body: '{"object_key":"123/abcdef1234"}')
      end

      it 'returns object key of deleted document' do
        expect(subject.call).to be(true)
      end
    end

    context 'when a document is not deleted successfully' do
      before do
        stub_request(:delete, 'http://datastore-webmock/api/v1/documents/MTIzL2FiY2RlZjEyMzQ=')
          .to_return(status: 500, body: '')
      end

      it 'returns object key of deleted document' do
        expect(subject.call).to be(false)
      end
    end
  end
end
