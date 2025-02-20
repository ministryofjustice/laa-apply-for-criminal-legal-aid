require 'rails_helper'

RSpec.describe Pagination do
  subject(:new) { described_class.new(**params) }

  let(:params) { {} }

  describe '#limit_value' do
    subject(:limit_value) { new.limit_value }

    context 'when a string number is provided' do
      let(:params) { { limit_value: '35' } }

      it { is_expected.to be 35 }
    end

    context 'when an integer' do
      let(:params) { { limit_value: 40 } }

      it { is_expected.to be 40 }
    end

    context 'when no attribute provided' do
      it { is_expected.to be 30 }
    end
  end
end
