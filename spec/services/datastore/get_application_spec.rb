require 'rails_helper'

RSpec.describe Datastore::GetApplication do
  subject { described_class.new('12345') }

  let(:endpoint) { 'http://datastore-webmock/api/v1/applications/12345' }
  let(:datastore_result) { '{"status":"submitted"}' }

  before do
    stub_request(:get, endpoint).to_return(body: datastore_result)
  end

  describe '#call' do
    it 'returns the application' do
      expect(subject.call).to be_a(DatastoreApi::Responses::ApplicationResult)
    end

    context 'for a superseded application' do
      let(:datastore_result) { '{"status":"superseded"}' }

      it 'raises `ApplicationNotFound`' do
        expect { subject.call }.to raise_exception(Errors::ApplicationNotFound)
      end
    end
  end

  context 'handling of errors' do
    before do
      stub_request(:get, endpoint).to_raise(error)
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
