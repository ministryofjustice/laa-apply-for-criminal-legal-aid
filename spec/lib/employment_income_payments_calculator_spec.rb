require 'rails_helper'

describe EmploymentIncomePaymentsCalculator do
  subject { described_class.annualized_payments(crime_application) }

  let(:crime_application) { CrimeApplication.new(income: income, income_payments: [income_payment1, income_payment2]) }
  let(:income) { Income.new(employment_status: ['employed']) }

  let(:income_payment1) {
    IncomePayment.new(amount: 100, frequency: 'week', ownership_type: 'applicant', payment_type: 'employment')
  }
  let(:income_payment2) {
    IncomePayment.new(amount: 100, frequency: 'week', ownership_type: 'applicant', payment_type: 'employment')
  }

  describe '#annualized_payments' do
    context 'when single employment for client and partner' do
      context 'when client and partner has no employment' do
        it 'has the right value' do
          expect(subject.count).to eq(0)
          expect(subject).to be_empty
        end
      end
    end

    context 'when multiple employments for client and partner' do
      before do
        allow_any_instance_of(Employment).to receive(:complete?).and_return(true)
        allow_any_instance_of(Deduction).to receive(:complete?).and_return(true)
      end

      context 'when client and partner has no employments' do
        it 'has the right value' do
          expect(subject.count).to eq(0)
          expect(subject).to be_empty
        end
      end

      context 'when client has employments' do
        before do
          create_employments('applicant')
        end

        it 'has the right value' do
          expect(subject.count).to eq(1)
          expect(subject).to contain_exactly({
                                               amount: 196_000,
                                               frequency: 'annual',
                                               income_tax: 63_700,
                                               national_insurance: 2400,
                                               ownership_type: 'applicant'
                                             })
        end
      end

      context 'when partner has employments' do
        before do
          create_employments('partner')
        end

        it 'has the right value' do
          expect(subject.count).to eq(1)
          expect(subject).to contain_exactly({
                                               amount: 196_000,
                                               frequency: 'annual',
                                               income_tax: 63_700,
                                               national_insurance: 2400,
                                               ownership_type: 'partner'
                                             })
        end
      end

      context 'when client and partner has employments' do
        before do
          create_employments('applicant')
          create_employments('partner')
        end

        it 'has the right value' do
          expect(subject.count).to eq(2)
          expect(subject).to contain_exactly({
                                               amount: 196_000,
                                               frequency: 'annual',
                                               income_tax: 63_700,
                                               national_insurance: 2400,
                                               ownership_type: 'applicant'
                                             }, {
                                               amount: 196_000,
                                               frequency: 'annual',
                                               income_tax: 63_700,
                                               national_insurance: 2400,
                                               ownership_type: 'partner'
                                             })
        end
      end
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_employments(ownership_type)
    employments = [
      Employment.new(amount: 1000,
                     frequency: PaymentFrequencyType::WEEKLY.to_s,
                     deductions: [
                       Deduction.new(
                         deduction_type: DeductionType::INCOME_TAX.to_s,
                         amount: 500,
                         frequency: PaymentFrequencyType::WEEKLY.to_s
                       ) # Deduction annually: 26000
                     ],
                     ownership_type: ownership_type), # Employment annually: 52000
      Employment.new(amount: 2000,
                     frequency: PaymentFrequencyType::FORTNIGHTLY.to_s,
                     deductions: [],
                     ownership_type: ownership_type), # Employment annually: 52000
      Employment.new(amount: 3000,
                     frequency: PaymentFrequencyType::FOUR_WEEKLY.to_s,
                     deductions: [
                       Deduction.new(
                         deduction_type: DeductionType::INCOME_TAX.to_s,
                         amount: 500,
                         frequency: PaymentFrequencyType::FOUR_WEEKLY.to_s
                       ), # Deduction annually: 6500
                       Deduction.new(
                         deduction_type: DeductionType::NATIONAL_INSURANCE.to_s,
                         amount: 200,
                         frequency: PaymentFrequencyType::MONTHLY.to_s
                       ) # Deduction annually: 2400
                     ],
                     ownership_type: ownership_type), # Employment annually: 39000
      Employment.new(amount: 4000,
                     frequency: PaymentFrequencyType::MONTHLY.to_s,
                     deductions: [
                       Deduction.new(
                         deduction_type: DeductionType::INCOME_TAX.to_s,
                         amount: 600,
                         frequency: PaymentFrequencyType::WEEKLY.to_s
                       ), # Deduction annually: 31200
                       Deduction.new(
                         deduction_type: DeductionType::OTHER.to_s,
                         amount: 700,
                         frequency: PaymentFrequencyType::WEEKLY.to_s
                       ) # Deduction annually: 36400
                     ],
                     ownership_type: ownership_type), # Employment annually: 48000
      Employment.new(amount: 5000,
                     frequency: PaymentFrequencyType::ANNUALLY.to_s,
                     deductions: [
                       Deduction.new(
                         deduction_type: DeductionType::OTHER.to_s,
                         amount: 800,
                         frequency: PaymentFrequencyType::ANNUALLY.to_s
                       ) # Deduction annually: 800
                     ],
                     ownership_type: ownership_type), # Employment annually: 5000
    ]
    crime_application.employments << employments
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
