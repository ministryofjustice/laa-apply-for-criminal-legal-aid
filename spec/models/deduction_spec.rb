require 'rails_helper'

RSpec.describe Deduction, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      deduction_type: 'income_tax',
      amount: 500,
      frequency: 'week',
      details: nil,
      employment_id: instance_double(Employment, id: 'uuid').id
    }
  end

  describe '#complete?' do
    context 'with valid attributes' do
      it 'returns true' do
        puts 'hiii'
        puts subject.inspect
        expect(subject.complete?).to be(true)
      end

      context 'when details are missing for `income_tax`' do
        before { attributes.merge!(deduction_type: 'income_tax', details: nil) }

        it 'returns true' do
          expect(subject.complete?).to be(true)
        end
      end
    end

    context 'with invalid attributes' do
      context 'when amount is nil' do
        before { attributes.merge!(amount: nil) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end

      context 'when details are missing for `other`' do
        before { attributes.merge!(deduction_type: 'other', details: nil) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end
    end
  end
end
