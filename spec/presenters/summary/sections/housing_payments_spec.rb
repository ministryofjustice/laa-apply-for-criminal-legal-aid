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
      amount: 333.0,
      frequency: 'year'
    )
  end

  let(:rent_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'rent',
      amount: 5555.0,
      frequency: 'month'
    )
  end

  let(:council_tax_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'council_tax',
      amount: 6666.0,
      frequency: 'annual'
    )
  end

  let(:board_and_lodging_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'board_and_lodging',
      amount: 750.0,
      frequency: 'month',
      board_amount: 800.0,
      food_amount: 50.0,
      payee_name: 'George',
      payee_relationship_to_client: 'Friend'
    )
  end

  # A legitimate outgoing but should not be shown in this section
  let(:maintenance_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'maintenance',
      amount: 101.0,
      frequency: 'week'
    )
  end

  before do
    allow(outgoings).to receive_messages(
      mortgage: nil,
      board_and_lodging: nil,
      council_tax: nil,
      rent: nil
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
      before do
        allow(outgoings).to receive_messages(
          council_tax: council_tax_payment
        )
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:housing_payment_type)
        expect(answers[0].change_path)
          .to match('applications/12345/steps/outgoings/housing-payments-where-lives')
        expect(answers[0].value).to eq('rent')

        expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[1].question).to eq(:pays_council_tax)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/pay-council-tax')
        expect(answers[1].value).to eq('yes')

        expect(answers[2]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[2].question).to eq(:council_tax)
        expect(answers[2].change_path)
          .to match('applications/12345/steps/outgoings/pay-council-tax')
        expect(answers[2].value.amount).to eq(6666)
        expect(answers[2].value.frequency).to eq('annual')
      end
    end

    context 'with mortgage and council_tax payment' do
      before do
        allow(outgoings).to receive_messages(
          mortgage: mortgage_payment,
          maintenance: maintenance_payment,
          council_tax: council_tax_payment
        )
      end

      it 'shows this section' do
        expect(answers.count).to eq(4)

        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:mortgage)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/mortgage-payments')
        expect(answers[1].value.amount).to eq(333)
        expect(answers[1].value.frequency).to eq('year')

        expect(answers[2].question).to eq(:pays_council_tax)
        expect(answers[3].question).to eq(:council_tax)
      end
    end

    context 'with rent and council_tax payment' do
      before do
        allow(outgoings).to receive_messages(
          maintenance: maintenance_payment,
          council_tax: council_tax_payment,
          rent: rent_payment
        )
      end

      it 'shows this section' do
        expect(answers.count).to eq(4)

        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:rent)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/rent-payments')
        expect(answers[1].value.amount).to eq(5555)
        expect(answers[1].value.frequency).to eq('month')

        expect(answers[2].question).to eq(:pays_council_tax)
        expect(answers[3].question).to eq(:council_tax)
      end
    end

    context 'with mortgage' do
      before do
        allow(outgoings).to receive_messages(
          mortgage: mortgage_payment,
          maintenance: maintenance_payment
        )
      end

      it 'shows this section' do
        expect(answers.count).to eq(3)
        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:mortgage)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/mortgage-payments')
        expect(answers[1].value.amount).to eq(333)
        expect(answers[1].value.frequency).to eq('year')
      end
    end

    context 'with rent' do
      before do
        allow(outgoings).to receive_messages(
          maintenance: maintenance_payment,
          rent: rent_payment
        )
      end

      it 'shows this section' do
        expect(answers.count).to eq(3)
        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:rent)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/rent-payments')
        expect(answers[1].value.amount).to eq(5555)
        expect(answers[1].value.frequency).to eq('month')
      end
    end

    context 'with board and lodging' do
      before do
        allow(outgoings).to receive_messages(
          board_and_lodging: board_and_lodging_payment
        )
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(5)

        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:board_amount)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/board-and-lodging-payments')
        expect(answers[1].value.amount).to eq('800.00')
        expect(answers[2].value.frequency.value).to eq(:month)

        expect(answers[2]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[2].question).to eq(:food_amount)
        expect(answers[2].change_path)
          .to match('applications/12345/steps/outgoings/board-and-lodging-payments')
        expect(answers[2].value.amount).to eq('50.00')
        expect(answers[2].value.frequency.value).to eq(:month)

        expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[3].question).to eq(:payee_name)
        expect(answers[3].change_path)
          .to match('applications/12345/steps/outgoings/board-and-lodging-payments')
        expect(answers[3].value).to eq('George')

        expect(answers[4]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[4].question).to eq(:payee_relationship_to_client)
        expect(answers[4].change_path)
          .to match('applications/12345/steps/outgoings/board-and-lodging-payments')
        expect(answers[4].value).to eq('Friend')
      end
    end
  end
end
