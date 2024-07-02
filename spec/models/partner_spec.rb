require 'rails_helper'

RSpec.describe Partner, type: :model do
  subject(:partner) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe '#has_passporting_benefit' do
    context 'when `benefit_type` is Universal Credit' do
      let(:attributes) { { benefit_type: 'universal_credit' } }

      it 'returns true' do
        expect(subject.has_passporting_benefit?).to be true
      end
    end

    context 'when `benefit_type` is invalid' do
      let(:attributes) { { benefit_type: 'invalid_benefit_type' } }

      it 'returns false' do
        expect(subject.has_passporting_benefit?).to be false
      end
    end

    context 'when `benefit_type` is none' do
      let(:attributes) { { benefit_type: 'none' } }

      it 'returns false' do
        expect(subject.has_passporting_benefit?).to be false
      end
    end
  end
end
