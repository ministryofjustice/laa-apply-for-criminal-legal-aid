require 'rails_helper'

RSpec.describe Steps::Income::BusinessPercentageProfitShareForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  it_behaves_like 'a form with a from_subject'

  describe '#save' do
    context 'when valid' do
      let(:attributes) { { percentage_profit_share: 70 } }

      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)
        expect(subject.save).to be(true)
      end
    end

    context 'when invalid' do
      let(:attributes) { { percentage_profit_share: '' } }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end

      it 'adds an error' do
        subject.save
        expect(subject.errors.of_kind?(:percentage_profit_share, :not_a_number)).to be(true)
      end

      context 'when the percentage is greater than 100' do
        let(:attributes) { { percentage_profit_share: 200 } }

        it 'does not update record' do
          expect(record).not_to receive(:update)
          expect(subject.save).to be(false)
        end

        it 'adds an error' do
          subject.save
          expect(subject.errors.of_kind?(:percentage_profit_share, :less_than_or_equal_to)).to be(true)
        end
      end

      context 'when the percentage is less than 0' do
        let(:attributes) { { percentage_profit_share: -1 } }

        it 'does not update record' do
          expect(record).not_to receive(:update)
          expect(subject.save).to be(false)
        end

        it 'adds an error' do
          subject.save
          expect(subject.errors.of_kind?(:percentage_profit_share, :greater_than_or_equal_to)).to be(true)
        end
      end
    end
  end
end
