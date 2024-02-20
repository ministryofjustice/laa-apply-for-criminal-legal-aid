require 'rails_helper'

RSpec.describe Steps::Capital::SavingTypeForm do
  subject(:form) { described_class.new }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([SavingType::BANK, SavingType::BUILDING_SOCIETY, SavingType::CASH_ISA,
               SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE, SavingType::OTHER])
    end
  end
end
