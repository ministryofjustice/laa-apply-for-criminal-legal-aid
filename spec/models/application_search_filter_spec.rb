require 'rails_helper'

RSpec.describe ApplicationSearchFilter do
  subject(:new) { described_class.new(**params) }

  let(:params) { {} }

  describe '#datastore_params' do
    subject(:datastore_params) { new.datastore_params }

    context 'when the filter is empty' do
      let(:expected_datastore_params) do
        {
          office_code: nil,
          search_text: nil,
          status: nil,
        }
      end

      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq(expected_datastore_params)
      end
    end

    context 'when all filters set' do
      let(:params) do
        {
          search_text: 'David 100003', office_code: '1A123B', status: %w[submitted returned]
        }
      end

      let(:expected_datastore_params) do
        {
          search_text: 'David 100003', office_code: '1A123B', status: %w[submitted returned]
        }
      end

      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq expected_datastore_params
      end
    end
  end
end
