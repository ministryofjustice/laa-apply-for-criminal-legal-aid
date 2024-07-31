require 'rails_helper'

RSpec.describe Steps::Income::BusinessTotalIncomeShareSalesForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  it_behaves_like 'a form with a from_subject'

  describe '#validation' do
    it {
      expect(subject).to validate_presence_of(
        :total_income_share_sales_amount, :blank, 'Enter the amount'
      )
    }
  end

  describe '#save' do
    context 'when `total_income_share_sales_amount` is valid' do
      let(:attributes) { { total_income_share_sales_amount: '120.01' } }

      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end

      it 'saves the details' do
        subject.save

        expect(subject.total_income_share_sales.frequency.to_s).to eq 'annual'
        expect(subject.total_income_share_sales.amount).to eq 12_001
      end
    end

    context 'when `total_income_share_sales_amount` is invalid' do
      let(:attributes) { { total_income_share_sales_amount: nil } }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end
  end
end
