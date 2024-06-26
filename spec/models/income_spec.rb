require 'rails_helper'

RSpec.describe Income, type: :model do
  subject(:income) { described_class.new }

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }

    before do
      allow(IncomeAssessment::AnswersValidator).to receive(:new).with(record: income)
                                                                .and_return(answers_validator)
    end

    describe 'valid?(:submission)' do
      it 'validates answers' do
        expect(answers_validator).to receive(:validate)

        income.valid?(:submission)
      end
    end
  end

  describe '#complete?' do
    context 'when income is complete' do
      it 'returns true' do
        expect(income).to receive(:valid?).with(:submission).and_return(true)
        expect(income.complete?).to be true
      end
    end

    context 'when income is incomplete' do
      it 'returns false' do
        expect(income).to receive(:valid?).with(:submission).and_return(false)
        expect(income.complete?).to be false
      end
    end
  end

  describe '#all_income_over_zero?' do
    subject(:all_income_over_zero) { income.all_income_over_zero? }

    context 'when there are any income payments or benefits' do
      let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'none') }

      before do
        partner = Partner.new

        crime_application = CrimeApplication.new(
          income:, partner_detail:, partner:
        )

        crime_application.income_payments = [
          IncomePayment.new(
            payment_type: 'maintenance',
            ownership_type: 'applicant',
            amount: 100,
            frequency: 'week',
          ),
          IncomePayment.new(
            payment_type: 'maintenance',
            ownership_type: 'partner',
            amount: 200,
            frequency: 'week',
          ),
        ]

        crime_application.income_benefits = [
          IncomeBenefit.new(
            payment_type: 'jsa',
            ownership_type: 'applicant',
            amount: 100,
            frequency: 'week',
          ),
          IncomeBenefit.new(
            payment_type: 'jsa',
            ownership_type: 'partner',
            amount: 200,
            frequency: 'week',
          ),
        ]

        income.has_no_income_payments = 'no'
        income.partner_has_no_income_payments = 'no'
        income.has_no_income_benefits = 'no'
        income.partner_has_no_income_benefits = 'no'

        crime_application.save!
      end

      it { is_expected.to be true }

      it 'calculates the correct total' do
        expect(income.all_income_total).to eq 600
      end

      context 'when partner has contrary interest' do
        let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'victim') }

        it 'only includes applicant payments' do
          expect(income.all_income_total).to eq 200
        end
      end
    end

    context 'when there is employment income' do
      before do
        crime_application = CrimeApplication.new(income:)
        crime_application.employments = [
          Employment.new(amount: 12_000)
        ]
      end

      it { is_expected.to be true }

      it 'calculates the correct total' do
        expect(income.all_income_total).to eq 12_000
      end
    end

    context 'when there are no income payments or benefits' do
      before { CrimeApplication.new(income:) }

      it { is_expected.to be false }

      it 'calculates the correct total' do
        expect(income.all_income_total).to eq 0
      end
    end
  end
end
