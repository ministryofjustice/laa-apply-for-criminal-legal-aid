require 'rails_helper'

RSpec.describe OutgoingsPayment, type: :model do
  subject(:outgoings_payment) { described_class.new }

  describe '#food_amount' do
    it 'converts integer pennies to string pounds' do
      outgoings_payment.attributes['metadata']['food_amount'] = 1399

      expect(outgoings_payment.food_amount).to eq('13.99')
    end
  end

  describe '#food_amount=' do
    it 'converts string pounds to integer pennies' do
      outgoings_payment.food_amount = '13.99'

      expect(outgoings_payment.attributes.dig('metadata', 'food_amount')).to eq(1399)
    end
  end

  describe '#board_amount' do
    it 'converts integer pennies to string pounds' do
      outgoings_payment.attributes['metadata']['board_amount'] = 1399

      expect(outgoings_payment.board_amount).to eq('13.99')
    end
  end

  describe '#board_amount=' do
    it 'converts string pounds to integer pennies' do
      outgoings_payment.board_amount = '13.99'

      expect(outgoings_payment.attributes.dig('metadata', 'board_amount')).to eq(1399)
    end
  end
end
