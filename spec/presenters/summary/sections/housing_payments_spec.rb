require 'rails_helper'

describe Summary::Sections::HousingPayments do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      outgoings: outgoings,
      outgoings_payments: outgoings_payments,
    )
  end

  let(:outgoings) do
    instance_double(
      Outgoings,
      housing_payment_type: 'rent'
    )
  end

  let(:outgoings_payments) do
    []
  end

  let(:mortgage_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'mortgage',
      amount: 333,
      frequency: 'year'
    )
  end

  let(:rent_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'rent',
      amount: 5555,
      frequency: 'month'
    )
  end

  # A legitimate outgoing but should not be shown in this section
  let(:maintenance_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'maintenance',
      amount: 101,
      frequency: 'week'
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:housing_payments) }
  end

  describe '#show?' do
    context 'when there is a housing_payments' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no housing_payments' do
      let(:outgoings) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are outgoings details' do
      it 'has the correct rows' do
        expect(answers.count).to eq(1)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:housing_payment_type)
        expect(answers[0].change_path)
          .to match('applications/12345/steps/outgoings/housing_payments_where_client_lives')
        expect(answers[0].value).to eq('rent')
      end
    end

    context 'with mortgage' do
      let(:outgoings_payments) do
        [
          mortgage_payment,
          maintenance_payment,
        ]
      end

      it 'shows this section' do
        expect(answers.count).to eq(2)
        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:mortgage)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/mortgage_payments')
        expect(answers[1].value.amount).to eq(333)
        expect(answers[1].value.frequency).to eq('year')
      end
    end

    context 'with rent' do
      let(:outgoings_payments) do
        [
          rent_payment,
          maintenance_payment,
        ]
      end

      it 'shows this section' do
        expect(answers.count).to eq(2)
        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:rent)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/rent_payments')
        expect(answers[1].value.amount).to eq(5555)
        expect(answers[1].value.frequency).to eq('month')
      end
    end
  end
end
