require 'rails_helper'

RSpec.describe Steps::Income::Client::SelfAssessmentTaxBillForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      applicant_self_assessment_tax_bill:,
      applicant_self_assessment_tax_bill_amount:,
      applicant_self_assessment_tax_bill_frequency:
    }
  end

  let(:crime_application) { CrimeApplication.new(income:) }
  let(:income) { Income.new }

  let(:applicant_self_assessment_tax_bill) { 'yes' }
  let(:applicant_self_assessment_tax_bill_amount) { 100_000 }
  let(:applicant_self_assessment_tax_bill_frequency) { 'four_weeks' }

  describe '#save' do
    context 'when `applicant_self_assessment_tax_bill` is not provided' do
      let(:applicant_self_assessment_tax_bill) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:applicant_self_assessment_tax_bill, :inclusion)).to be(true)
      end
    end

    context 'when `applicant_self_assessment_tax_bill` is `Yes`' do
      let(:applicant_self_assessment_tax_bill) { YesNoAnswer::YES.to_s }

      context 'when `amount` is not provided' do
        let(:applicant_self_assessment_tax_bill_amount) { nil }

        it 'returns false' do
          expect(form.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:applicant_self_assessment_tax_bill_amount, :not_a_number)).to be(true)
        end
      end

      context 'when `frequency` is not valid' do
        let(:applicant_self_assessment_tax_bill_frequency) { 'every six weeks' }

        it 'returns false' do
          expect(form.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:applicant_self_assessment_tax_bill_frequency, :inclusion)).to be(true)
        end
      end

      context 'when all attributes are valid' do
        let(:applicant_self_assessment_tax_bill_amount) { '100' }
        let(:applicant_self_assessment_tax_bill_frequency) { PaymentFrequencyType::MONTHLY.to_s }

        it { is_expected.to be_valid }

        it 'returns true' do
          expect(subject.save).to be(true)
        end

        it 'passes validation' do
          expect(form.errors.of_kind?(:applicant_self_assessment_tax_bill_amount, :invalid)).to be(false)
        end
      end

      context 'when amount is zero' do
        let(:applicant_self_assessment_tax_bill_amount) { '0' }
        let(:applicant_self_assessment_tax_bill_frequency) { PaymentFrequencyType::MONTHLY.to_s }

        it { is_expected.to be_valid }
      end
    end

    context 'when `applicant_self_assessment_tax_bill` is `No`' do
      let(:applicant_self_assessment_tax_bill) { YesNoAnswer::NO.to_s }

      context 'when `amount` is not provided' do
        let(:applicant_self_assessment_tax_bill_amount) { nil }

        it 'passes validation' do
          expect(form.errors.of_kind?(:applicant_self_assessment_tax_bill_amount, :invalid)).to be(false)
        end
      end

      context 'when `frequency` is not valid' do
        let(:applicant_self_assessment_tax_bill_frequency) { 'every six weeks' }

        it 'passes validation' do
          expect(form.errors.of_kind?(:applicant_self_assessment_tax_bill_amount, :invalid)).to be(false)
        end
      end
    end
  end
end
