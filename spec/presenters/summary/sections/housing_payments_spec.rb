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
      housing_payment_type: 'rent',
      pays_council_tax: 'yes',
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

  let(:council_tax_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'council_tax',
      amount: 6666,
      frequency: 'annual'
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
    context 'when there is a housing_payments and no council_tax payment' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no housing_payments and no council_tax payment' do
      let(:outgoings) { nil }
      let(:outgoings_payments) { [] }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when there is no housing_payments but has council_tax payment' do
      let(:outgoing_payments) do
        [
          council_tax_payment
        ]
      end

      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are outgoings detail and council_tax payment' do
      let(:outgoings_payments) do
        [
          council_tax_payment
        ]
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:housing_payment_type)
        expect(answers[0].change_path)
          .to match('applications/12345/steps/outgoings/housing_payments_where_client_lives')
        expect(answers[0].value).to eq('rent')

        expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[1].question).to eq(:pays_council_tax)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/does_client_pay_council_tax')
        expect(answers[1].value).to eq('yes')

        expect(answers[2]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[2].question).to eq(:council_tax)
        expect(answers[2].change_path)
          .to match('applications/12345/steps/outgoings/does_client_pay_council_tax')
        expect(answers[2].value.amount).to eq(6666)
      end
    end

    context 'with mortgage and council_tax payment' do
      let(:outgoings_payments) do
        [
          mortgage_payment,
          maintenance_payment,
          council_tax_payment,
        ]
      end

      it 'shows this section' do
        expect(answers.count).to eq(4)

        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:mortgage)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/mortgage_payments')
        expect(answers[1].value.amount).to eq(333)
        expect(answers[1].value.frequency).to eq('year')

        expect(answers[2].question).to eq(:pays_council_tax)
        expect(answers[3].question).to eq(:council_tax)
      end
    end

    context 'with rent and council_tax payment' do
      let(:outgoings_payments) do
        [
          rent_payment,
          maintenance_payment,
          council_tax_payment,
        ]
      end

      it 'shows this section' do
        expect(answers.count).to eq(4)

        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:rent)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/rent_payments')
        expect(answers[1].value.amount).to eq(5555)
        expect(answers[1].value.frequency).to eq('month')

        expect(answers[2].question).to eq(:pays_council_tax)
        expect(answers[3].question).to eq(:council_tax)
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
