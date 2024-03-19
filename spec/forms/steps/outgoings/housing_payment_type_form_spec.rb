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
        form.housing_payment_type = housing_payment_type
        form.save
      end

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:housing_payment_type, :invalid)).to be(false)
      end

      it 'updates the outgoings record' do
        expect(crime_application.outgoings.housing_payment_type.to_s).to eq(housing_payment_type.to_s)
      end
    end

    context 'when there were existing housing payments different to selected value' do
      let(:older_housing_payment) do
        OutgoingsPayment.new(
          payment_type: 'board_and_lodging',
          frequency: PaymentFrequencyType::FOUR_WEEKLY,
          amount: 890.02,
        )
      end

      before do
        crime_application.outgoings_payments << older_housing_payment
        crime_application.outgoings.housing_payment_type = 'board_and_lodging'

        allow(crime_application.outgoings_payments).to(
          receive(:housing_payments).and_return(crime_application.outgoings_payments)
        )
      end

      it 'deletes them all' do
        expect(crime_application.outgoings_payments.housing_payments).to receive(:destroy_all)

        form.housing_payment_type = HousingPaymentType::RENT
        form.save
      end
    end

    context 'when board and lodging is saved' do
      let(:council_tax_payment) do
        OutgoingsPayment.new(
          payment_type: 'council_tax',
          frequency: PaymentFrequencyType::ANNUALLY,
          amount: 1200.00,
        )
      end

      let(:maintenance_payment) do
        OutgoingsPayment.new(
          payment_type: 'maintenance',
          frequency: PaymentFrequencyType::ANNUALLY,
          amount: 100.00,
        )
      end

      before do
        crime_application.outgoings_payments << council_tax_payment
        crime_application.outgoings_payments << maintenance_payment
        crime_application.outgoings.pays_council_tax = 'yes'
      end

      it 'deletes any existing council tax payments' do
        expect(crime_application.outgoings_payments).to contain_exactly(council_tax_payment, maintenance_payment)

        form.housing_payment_type = HousingPaymentType::BOARD_AND_LODGING
        form.save

        expect(crime_application.outgoings_payments.reload).to contain_exactly(maintenance_payment)
      end

      it 'resets outgoings.pays_council_tax' do
        form.housing_payment_type = HousingPaymentType::BOARD_AND_LODGING

        expect { form.save }.to(
          change(crime_application.outgoings, :pays_council_tax).from('yes').to(nil)
        )
      end
    end
  end
end
