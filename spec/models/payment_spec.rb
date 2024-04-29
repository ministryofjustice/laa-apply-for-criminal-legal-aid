require 'rails_helper'

RSpec.describe Payment, type: :model do
  subject(:payment) { described_class.new(**attributes) }

  describe '#complete?' do
    subject(:complete) { payment.complete? }

    let(:attributes) { { amount: 1, payment_type: 'rent', frequency: 'week' } }

    context 'all attributes present' do
      it { is_expected.to be true }
    end

    context 'an attribute is missing' do
      let(:attributes) { super().to_a.sample(2).to_h }

      it { is_expected.to be false }
    end
  end

  describe '#prorated_monthly' do
    let(:attributes) { { amount: 12_000 * 100, payment_type: 'rent', frequency: 'annual' } }

    it 'calculates amount using frequency', :aggregate_failures do
      tests = [
        [{ amount: 123.09, frequency: 'week', payment_type: 'rent' }, 533.39],
        [{ amount: 200.01, frequency: 'fortnight', payment_type: 'rent' }, 433.35],
        [{ amount: 1.09, frequency: 'four_weeks', payment_type: 'rent' }, 1.18],
        [{ amount: 123.09, frequency: 'month', payment_type: 'rent' }, 123.09],
        [{ amount: 12_000.99, frequency: 'annual', payment_type: 'rent' }, 1000.08],
        [{ amount: -1.99, frequency: 'month', payment_type: 'rent' }, -1.99],
        [{ amount: 0, frequency: 'annual', payment_type: 'rent' }, 0],
        [{ amount: nil, frequency: 'annual', payment_type: 'rent' }, 0],
        [{ amount: 123.09, frequency: 'badfrequency', payment_type: 'rent' }, 123.09],
      ]

      tests.each do |test|
        payment = described_class.new(**test[0])
        expect(payment.prorated_monthly.to_f).to eq(test[1])
      end
    end
  end
end
