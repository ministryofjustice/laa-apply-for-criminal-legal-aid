require 'rails_helper'

RSpec.describe Steps::Income::BusinessFinancialsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  let(:valid_attributes) do
    {
      turnover: { amount: '123000.01', frequency: 'annual' },
      drawings: { amount: '0.31', frequency: 'week' },
      profit: { amount: '2800.00', frequency: 'month' }
    }
  end

  it_behaves_like 'a form with a from_subject'

  describe '#save' do
    let(:attributes) { valid_attributes }

    context 'when all payments valid' do
      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when a payments is invalid' do
      let(:attributes) { valid_attributes.deep_merge(turnover: { amount: nil }) }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end

      it 'adds an error' do
        subject.save
        expect(form.errors.added?(:turnover, :amount_blank)).to be true
      end
    end

    context 'when a frequency is missing' do
      let(:attributes) { valid_attributes.deep_merge(profit: { frequency: nil }) }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end

      it 'adds an error' do
        subject.save
        expect(form.errors.added?(:profit, :frequency_blank)).to be true
      end
    end
  end

  describe '#financials' do
    it 'returns a list of payments' do
      expect(form.financials).to contain_exactly :turnover, :drawings, :profit
    end
  end
end
