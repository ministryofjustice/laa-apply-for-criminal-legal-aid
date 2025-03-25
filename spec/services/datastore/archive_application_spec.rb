require 'rails_helper'

RSpec.describe Datastore::ArchiveApplication do
  subject { described_class.new('12345') }

  let(:endpoint) { 'http://datastore-webmock/api/v1/applications/12345/archive' }

  before do
    stub_request(:put, endpoint).to_return(body: 'true')
  end

  describe '#call' do
    it 'archives the application' do
      expect(subject.call).to be(true)
    end
  end
end
