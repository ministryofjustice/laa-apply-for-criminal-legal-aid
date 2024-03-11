require 'rails_helper'

RSpec.describe Steps::Outgoings::HousingPaymentTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      housing_payment_type:,
    }
  end

  let(:crime_application) { CrimeApplication.new(outgoings:) }
  let(:outgoings) { Outgoings.new }
  let(:outgoings_payment) {
    OutgoingsPayment.new(crime_application: crime_application,
                         payment_type: OutgoingsPaymentType::BOARD_AND_LODGING)
  }

  let(:housing_payment_type) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([
                HousingPaymentType::RENT,
                HousingPaymentType::MORTGAGE,
                HousingPaymentType::BOARD_AND_LODGING,
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
      let(:housing_payment_type) { HousingPaymentType::RENT }

      before do
        allow(crime_application.outgoings_payments).to receive(:create).with(
          payment_type: housing_payment_type
        ).and_return outgoings_payment
        allow(form).to receive(:existing_housing_payment).and_return nil
        form.housing_payment_type = housing_payment_type
        form.save
      end

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:housing_payment_type, :invalid)).to be(false)
      end

      it 'updates the outgoings record' do
        expect(crime_application.outgoings.housing_payment_type).to eq(housing_payment_type.to_s)
      end

      it 'creates an outgoings payment object' do
        expect(subject.save).to eq(outgoings_payment)
      end
    end
  end
end
