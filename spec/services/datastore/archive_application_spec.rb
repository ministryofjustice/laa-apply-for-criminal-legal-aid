require 'rails_helper'

RSpec.describe Datastore::ArchiveApplication do
  subject { described_class.new('12345') }

  let(:endpoint) { 'http://datastore-webmock/api/v1/applications/12345/archive' }
  let(:datastore_result) { '{"status":"submitted"}' }

  before do
    stub_request(:post, endpoint).to_return(body: datastore_result)
  end

  describe '#call' do
    it 'archives the application' do
      expect(subject.call).to be(true)
    end
  end

  context 'handling of errors' do
    before do
      stub_request(:post, endpoint).to_raise(error)
    end

    context 'for API errors' do
      let(:error) { DatastoreApi::Errors::ConnectionError }

      it 'reports the exception and re-raises as `ApplicationNotFound' do
        expect(Rails.error).to receive(:report).with(
          an_instance_of(error), hash_including(handled: false)
        )

        expect { subject.call }.to raise_exception(Errors::ApplicationNotFound)
      end
    end

    context 'for other kind of errors' do
      let(:error) { StandardError }

      it 'reports the exception and lets it bubble up' do
        expect(Rails.error).to receive(:report).with(
          an_instance_of(error), hash_including(handled: false)
        )

        expect { subject.call }.to raise_exception(StandardError)
      end
    end
  end
end
