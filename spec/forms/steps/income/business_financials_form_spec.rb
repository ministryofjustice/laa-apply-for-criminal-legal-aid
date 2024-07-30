require 'rails_helper'

RSpec.describe Steps::Income::BusinessFinancialsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  let(:valid_attributes) do
    {
      turnover_amount: '123000.01',
      turnover_frequency: 'annual',
      drawings_amount: '0.31',
      drawings_frequency: 'week',
      profit_amount: '2800.00',
      profit_frequency: 'month'
    }
  end

  it_behaves_like 'a form with a from_subject'

  describe '#validation' do
    it {
      expect(subject).to validate_presence_of(
        :profit_frequency, :inclusion, 'Select what period this total profit was for'
      )
    }

    it {
      expect(subject).to validate_presence_of(
        :turnover_frequency, :inclusion, 'Select how often this amount was generated'
      )
    }

    it {
      expect(subject).to validate_presence_of(
        :drawings_frequency, :inclusion, 'Select how often this amount was drawn'
      )
    }

    it {
      expect(subject).to validate_presence_of(
        :profit_amount, :blank, 'Enter the total profit amount'
      )
    }

    it {
      expect(subject).to validate_presence_of(
        :turnover_amount, :blank, 'Enter the total turnover amount'
      )
    }

    it {
      expect(subject).to validate_presence_of(
        :drawings_amount, :blank, 'Enter the total drawings amount'
      )
    }
  end

  describe '#save' do
    let(:attributes) { valid_attributes }

    context 'when all payments valid' do
      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when a payments is invalid' do
      let(:attributes) { valid_attributes.merge(turnover_amount: nil) }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end

    context 'when a frequency is missing' do
      let(:attributes) { valid_attributes.merge(profit_frequency: nil) }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end
  end
end
