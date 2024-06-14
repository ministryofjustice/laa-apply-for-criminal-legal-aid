require 'rails_helper'

RSpec.describe Steps::Outgoings::CouncilTaxForm do
  let(:crime_application) { CrimeApplication.new(outgoings:) }

  let(:outgoings) { Outgoings.new }
  let(:outgoings_payment) do
    OutgoingsPayment.new(
      crime_application: crime_application,
      payment_type: OutgoingsPaymentType::COUNCIL_TAX,
      frequency: PaymentFrequencyType::ANNUALLY,
    )
  end

  describe '#build' do
    subject(:form) { described_class.build(crime_application) }

    it 'sets the crime_application' do
      expect(subject.crime_application).not_to be_nil
    end

    context 'when no council_tax payment exists' do
      it 'creates empty form if model does not exist' do
        expect(subject.amount).to be_nil
      end
    end

    context 'when council_tax payment exists' do
      let(:existing_council_tax_payment) {
        OutgoingsPayment.new(
          crime_application: crime_application,
          payment_type: OutgoingsPaymentType::COUNCIL_TAX,
          amount: 8999,
          frequency: 'annual',
        )
      }

      before do
        allow(crime_application.outgoings_payments).to receive(:council_tax).and_return(existing_council_tax_payment)
      end

      it 'loads model if it exists' do
        expect(subject.amount).to eq('89.99')
      end
    end
  end

  describe '#choices' do
    subject(:form) { described_class.new(crime_application:) }

    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(arguments) }

    let(:payments) do
      subject.crime_application.outgoing_payments
    end

    context 'when `pays_council_tax` is not provided' do
      let(:arguments) do
        { 'pays_council_tax' => nil, 'amount' => '91891' }.merge(crime_application:)
      end

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:pays_council_tax, :inclusion)).to be(true)
      end
    end

    context 'when `pays_council_tax` is not valid' do
      let(:arguments) do
        { 'pays_council_tax' => 'maybe', 'amount' => '91891' }.merge(crime_application:)
      end

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:pays_council_tax, :inclusion)).to be(true)
      end
    end

    context 'when `pays_council_tax` is yes' do
      let(:arguments) do
        { 'pays_council_tax' => 'yes', 'amount' => 91_891 }.merge(crime_application:)
      end

      before do
        allow(crime_application.outgoings_payments).to receive(:create!).with(
          payment_type: OutgoingsPaymentType::COUNCIL_TAX,
          amount: Money.new(91_891),
          frequency: PaymentFrequencyType::ANNUALLY,
        ).and_return(true)
      end

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:pays_council_tax, :invalid)).to be(false)
      end

      it 'deletes existing council_tax payments' do
        expect(form).to receive(:reset!)

        form.save
      end

      it 'creates an outgoings_payment record' do
        expect(crime_application.outgoings_payments).to receive(:create!).with(
          payment_type: OutgoingsPaymentType::COUNCIL_TAX,
          amount: Money.new(91_891),
          frequency: PaymentFrequencyType::ANNUALLY,
        ).once

        form.save
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :outgoings,
                      expected_attributes: {
                        pays_council_tax: YesNoAnswer::YES,
                      }
    end

    context 'when `pays_council_tax` answer is no' do
      let(:arguments) do
        { 'pays_council_tax' => 'no' }.merge(crime_application:)
      end

      it { is_expected.to be_valid }

      it 'deletes existing council_tax payments' do
        expect(form).to receive(:reset!)

        form.save
      end

      it 'does not create a new outgoings_payment record' do
        expect(crime_application.outgoings_payments).not_to receive(:create!)

        form.save
      end
    end

    context 'when housing_payment_type is board_and_lodging' do
      let(:arguments) do
        { 'pays_council_tax' => 'yes' }.merge(crime_application:)
      end

      before do
        crime_application.outgoings.housing_payment_type = 'board_and_lodging'
      end

      it 'is not payable' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:pays_council_tax, :not_payable)).to be(true)
      end
    end

    context 'when housing_payment_type is not board_and_lodging' do
      let(:arguments) do
        { 'pays_council_tax' => 'yes', 'amount' => 29_000 }.merge(crime_application:)
      end

      before do
        crime_application.outgoings.housing_payment_type = 'rent'
      end

      it { is_expected.to be_valid }
    end
  end

  describe '#amount' do
    let(:other_args) do
      { 'pays_council_tax' => 'yes' }
    end

    it_behaves_like 'a basic amount', described_class
  end
end
