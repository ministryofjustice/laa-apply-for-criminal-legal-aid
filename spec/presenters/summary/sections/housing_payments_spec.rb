require 'rails_helper'

describe Summary::Sections::HousingPayments do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      outgoings: outgoings,
    )
  end

  let(:outgoings) do
    instance_double(
      Outgoings,
      housing_payment_type: 'rent'
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
  end
end
