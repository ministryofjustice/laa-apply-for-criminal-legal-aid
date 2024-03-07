require 'rails_helper'

RSpec.describe Steps::Outgoings::MortgageForm do
  let(:crime_application) { CrimeApplication.new }

  describe '#build' do
    subject(:form) { described_class.build(crime_application) }

    context 'when no mortgage payment exists' do
      it 'creates empty form if model does not exist' do
        expect(subject.amount).to be_nil
        expect(subject.frequency).to be_nil
      end
    end

    context 'when mortgage payment exists' do
      let(:existing_mortgage_payment) {
        OutgoingsPayment.new(
          crime_application: crime_application,
          payment_type: OutgoingsPaymentType::MORTGAGE,
          amount: 8999,
          frequency: 'four_weeks',
        )
      }

      before do
        allow(crime_application.outgoings_payments).to receive(:mortgage).and_return(existing_mortgage_payment)
      end

      it 'loads model if it exists' do
        expect(subject.amount).to eq(8999)
        expect(subject.frequency).to eq(PaymentFrequencyType::FOUR_WEEKLY)
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(arguments) }

    let(:payments) do
      subject.crime_application.outgoings_payments
    end

    context 'with valid data' do
      before do
        allow(crime_application.outgoings_payments).to receive(:create!).and_return(true)

        form.save
      end

      let(:arguments) do
        { 'amount' => '91891', 'frequency' => 'month' }.merge(crime_application:)
      end

      it 'is valid' do
        expect(subject).to be_valid
        expect(subject.amount).to eq '91891'
        expect(subject.frequency).to eq PaymentFrequencyType::MONTHLY
      end
    end

    it_behaves_like 'a basic amount with frequency', described_class
  end
end
