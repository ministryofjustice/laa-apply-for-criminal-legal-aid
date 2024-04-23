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
end
