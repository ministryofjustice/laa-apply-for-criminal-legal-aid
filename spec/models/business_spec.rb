require 'rails_helper'

RSpec.describe Business, type: :model do
  subject(:business) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe '#turnover' do
    subject(:turnover) { business.turnover }

    it 'is has a default amount of nil' do
      expect(turnover.amount).to be_nil
      expect(turnover.frequency).to be_nil
    end

    it 'sets the amount as a money object' do
      business.turnover.amount = '12.00'
    end
  end
end
