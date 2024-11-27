require 'rails_helper'

RSpec.describe Pagination do
  subject(:new) { described_class.new(**params) }

  let(:params) { {} }

  describe '#limit_value' do
    subject(:limit_value) { new.limit_value }

    context 'when an string number is provided' do
      let(:params) { { limit_value: '35' } }

      it { is_expected.to be 35 }
    end

    context 'when an integer' do
      let(:params) { { limit_value: 30 } }

      it { is_expected.to be 30 }
    end

    context 'when no attribute provided' do
      it { is_expected.to be 50 }
    end
  end
end
