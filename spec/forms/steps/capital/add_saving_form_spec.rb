require 'rails_helper'

RSpec.describe Steps::Capital::AddSavingForm do
  subject(:form) { described_class.new }

  # let(:arguments) do
  #   {
  #     crime_application:,
  #     saving_type:
  #   }
  # end
  #
  # let(:crime_application) { instance_double(CrimeApplication, savings:) }
  # let(:savings) { Savings.new }
  #
  # let(:saving_type) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([SavingType::BANK, SavingType::BUILDING_SOCIETY, SavingType::CASH_ISA,
               SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE, SavingType::OTHER])
    end
  end
end
