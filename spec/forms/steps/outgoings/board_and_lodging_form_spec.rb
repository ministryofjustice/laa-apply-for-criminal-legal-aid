require 'rails_helper'

RSpec.describe Steps::Outgoings::BoardAndLodgingForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      board_amount:,
      food_amount:,
      frequency:,
      payee_name:,
      payee_relationship_to_client:
    }
  end

  let(:crime_application) { CrimeApplication.new }
  let(:outgoings_payment) {
    OutgoingsPayment.new(crime_application: crime_application,
                         payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.to_s)
  }

  let(:board_amount) { nil }
  let(:food_amount) { nil }
  let(:frequency) { nil }
  let(:payee_name) { nil }
  let(:payee_relationship_to_client) { nil }

  before do
    allow(crime_application.outgoings_payments).to receive(:find_by).with(
      { payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.to_s }
    ).and_return(outgoings_payment)
  end

  describe '#build' do
    subject(:form) { described_class.build(crime_application) }

    let(:existing_outgoings_payment) {
      OutgoingsPayment.new(crime_application: crime_application,
                           payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.to_s,
                           frequency: 'four_weeks',
                           amount: 600,
                           metadata: { 'board_amount' => 700, 'food_amount' => 100, 'payee_name' => 'Joan',
                                      'payee_relationship_to_client' => 'Landlady' })
    }

    before do
      allow(crime_application.outgoings_payments).to receive(:find_by).with(
        { payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.to_s }
      ).and_return(existing_outgoings_payment)
    end

    it 'sets the form attributes from the model metadata' do
      expect(form.board_amount).to eq(700)
      expect(form.food_amount).to eq(100)
      expect(form.frequency).to eq(PaymentFrequencyType::FOUR_WEEKLY)
      expect(form.payee_name).to eq('Joan')
      expect(form.payee_relationship_to_client).to eq('Landlady')
    end
  end

  describe '#save' do
    before do
      allow(crime_application.outgoings_payments).to receive(:create!).and_return(true)
    end

    context 'when `board_amount` is not provided' do
      let(:board_amount) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:board_amount, :blank)).to be(true)
      end
    end

    context 'when `food_amount` is not provided' do
      let(:food_amount) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:food_amount, :blank)).to be(true)
      end
    end

    context 'when `frequency` is not valid' do
      let(:frequency) { 'every six weeks' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:frequency, :inclusion)).to be(true)
      end
    end

    context 'when `payee_name` is not provided' do
      let(:payee_name) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:payee_name, :blank)).to be(true)
      end
    end

    context 'when `payee_relationship_to_client` is not provided' do
      let(:payee_relationship_to_client) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:payee_relationship_to_client, :blank)).to be(true)
      end
    end

    context 'when all attributes are valid' do
      let(:board_amount) { '600' }
      let(:food_amount) { '80' }
      let(:frequency) { 'month' }
      let(:payee_name) { 'John Doe' }
      let(:payee_relationship_to_client) { 'Landlord' }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:board_amount, :invalid)).to be(false)
      end

      it 'updates the outgoings payment with the correct attributes' do
        expect(crime_application.outgoings_payments).to receive(:create!).with(
          payment_type: :board_and_lodging,
          amount: 520.00,
          frequency: PaymentFrequencyType::MONTHLY,
          payee_name: 'John Doe',
          payee_relationship_to_client: 'Landlord',
          board_amount: 60_000,
          food_amount: 8_000,
        )

        form.save
      end

      context 'when amounts were previously recorded' do
        before do
          outgoings_payment.update(amount: 450)
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
