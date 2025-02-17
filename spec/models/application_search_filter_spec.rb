require 'rails_helper'

RSpec.describe ApplicationSearchFilter do
  subject(:new) { described_class.new(**params) }

  let(:params) { { office_code: } }
  let(:office_code) { '4hk1' }

  describe '#datastore_params' do
    subject(:datastore_params) { new.datastore_params }

    context 'when `office_code` is not given' do
      let(:office_code) { nil }

      it { expect { datastore_params }.to(raise_error { Errors::UnscopedDatastoreQuery }) }
    end

    it 'sets expected defaults' do
      expect(datastore_params).to eq(
        {
          office_code: office_code,
          search_text: nil,
          status: nil,
          review_status: nil
        }
      )
    end

    context 'when all filters set' do
      let(:params) do
        {
          search_text: 'David 100003',
          office_code: '1A123B',
          status: %w[submitted returned],
          review_status: ['application_recieved']
        }
      end

      let(:expected_datastore_params) do
        params
      end

      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq expected_datastore_params
      end
    end
  end
end
