require 'rails_helper'

RSpec.describe Steps::Outgoings::HousingPaymentTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      housing_payment_type:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, outgoings:) }
  let(:outgoings) { instance_double(Outgoings) }

  let(:housing_payment_type) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([
                HousingPaymentType::RENT,
                HousingPaymentType::MORTGAGE,
                HousingPaymentType::BOARD_LODGINGS,
                HousingPaymentType::NONE
              ])
    end
  end

  describe '#save' do
    context 'when `housing_payment_type` is blank' do
      let(:housing_payment_type) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:housing_payment_type, :inclusion)).to be(true)
      end
    end

    context 'when `housing_payment_type` is invalid' do
      let(:housing_payment_type) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:housing_payment_type, :inclusion)).to be(true)
      end
    end

    context 'when `housing_payment_type` is valid' do
      let(:housing_payment_type) { HousingPaymentType::RENT.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:housing_payment_type, :invalid)).to be(false)
      end

      it 'updates the record' do
        expect(outgoings).to receive(:update)
          .with({ 'housing_payment_type' => HousingPaymentType::RENT })
          .and_return(true)

        expect(subject.save).to be(true)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :outgoings,
                      expected_attributes: {
                        'housing_payment_type' => HousingPaymentType::RENT,
                      }
    end
  end
end
