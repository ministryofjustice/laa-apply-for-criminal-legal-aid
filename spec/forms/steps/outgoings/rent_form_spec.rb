require 'rails_helper'

RSpec.describe Steps::Outgoings::RentForm do
  let(:crime_application) { CrimeApplication.new }

  describe '#build' do
    subject(:form) { described_class.build(crime_application) }

    context 'when no rent payment exists' do
      it 'creates empty form if model does not exist' do
        expect(subject.amount).to be_nil
        expect(subject.frequency).to be_nil
      end
    end

    context 'when rent payment exists' do
      let(:existing_rent_payment) {
        OutgoingsPayment.new(
          crime_application: crime_application,
          payment_type: OutgoingsPaymentType::RENT.to_s,
          amount: 8999.0,
          frequency: 'four_weeks',
        )
      }

      before do
        allow(crime_application.outgoings_payments).to receive(:rent).and_return(existing_rent_payment)
      end

      it 'loads model if it exists' do
        expect(subject.amount).to eq('8999.00')
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
        expect(subject.amount).to eq '91891.00'
        expect(subject.frequency).to eq PaymentFrequencyType::MONTHLY
      end
    end

    it_behaves_like 'a basic amount with frequency', described_class
  end
end
