require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe PartnerEmploymentDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) do
    instance_double(
      Income,
      errors:,
      crime_application:,
      partner_employment_status:,
      partner_businesses:,
      partner_self_assessment_tax_bill:,
      partner_self_assessment_tax_bill_amount:,
      partner_self_assessment_tax_bill_frequency:,
      partner_other_work_benefit_received:,
      partner_employments:,
      partner_in_armed_forces:
    )
  end

  let(:errors) { double(:errors, empty?: false) }
  let(:crime_application) { instance_double(CrimeApplication, partner_employments:, partner_detail:, partner:) }
  let(:partner_employment_status) { [] }
  let(:partner_businesses) { [] }
  let(:partner_detail) { nil }
  let(:partner) { Partner.new(date_of_birth: '2000-01-01') }
  let(:partner_employments) { [] }
  let(:partner_self_assessment_tax_bill) { nil }
  let(:partner_self_assessment_tax_bill_amount) { nil }
  let(:partner_self_assessment_tax_bill_frequency) { nil }
  let(:partner_other_work_benefit_received) { nil }
  let(:partner_in_armed_forces) { nil }

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when means assessment required' do
      before do
        allow(validator).to receive_messages(requires_means_assessment?: true,
                                             include_partner_in_means_assessment?: true)
      end

      it { is_expected.to be(true) }
    end

    context 'when means assessment not required' do
      before do
        allow(validator).to receive(:requires_means_assessment?).and_return(false)
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#validate_employment_details' do
    subject(:validate) { validator.validate_employment_details }

    context 'when does not require a full means assessment' do
      before do
        allow(validator).to receive_messages(requires_full_means_assessment?: false,
                                             include_partner_in_means_assessment?: false)
      end

      it 'does not add errors' do
        expect(errors).not_to receive(:add)

        validate
      end
    end

    context 'when requires a full means assessment' do
      before do
        allow(validator).to receive_messages(requires_full_means_assessment?: true,
                                             include_partner_in_means_assessment?: true)
      end

      context 'when there are no partner employments' do
        let(:partner_other_work_benefit_received) { 'no' }
        let(:partner_self_assessment_tax_bill) { 'no' }
        let(:partner_employments) { [] }

        it 'adds an error to :partner_employments' do
          expect(errors).to receive(:add).with(:employments, :incomplete)

          validate
        end
      end

      context 'where there is an incomplete employment' do
        let(:partner_other_work_benefit_received) { 'no' }
        let(:partner_self_assessment_tax_bill) { 'no' }
        let(:partner_employments) { [instance_double(Employment, complete?: false, ownership_type: 'partner')] }

        it 'adds an error to :partner_employments' do
          expect(errors).to receive(:add).with(:employments, :incomplete)

          validate
        end
      end

      context 'when applicant_other_work_benefit_received is not present' do
        let(:partner_other_work_benefit_received) { nil }
        let(:partner_self_assessment_tax_bill) { 'no' }
        let(:partner_employments) { [instance_double(Employment, complete?: true, ownership_type: 'partner')] }

        it 'adds an error to :other_work_benefit' do
          expect(errors).to receive(:add).with(:partner_other_work_benefit_received, :incomplete)

          validate
        end
      end

      context 'when all requires attributes are present and complete' do
        let(:partner_other_work_benefit_received) { 'no' }
        let(:partner_self_assessment_tax_bill) { 'no' }
        let(:partner_employments) { [instance_double(Employment, complete?: true, ownership_type: 'partner')] }

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate_employment_income' do
    subject(:validate) { validator.validate_employment_income }

    context 'when requires a full means assessment' do
      before do
        allow(validator).to receive(:requires_full_means_assessment?).and_return(true)
      end

      it 'does not add errors' do
        expect(errors).not_to receive(:add)

        validate
      end
    end

    context 'when does not require a full means assessment' do
      before do
        allow(validator).to receive(:requires_full_means_assessment?).and_return(false)
        allow(record).to receive(:partner_employment_income) { partner_employment_income }
      end

      context 'when no employment income payment exists' do
        let(:partner_employment_income) { nil }

        it 'adds an error to :employment_income' do
          expect(errors).to receive(:add).with(:employment_income, :incomplete)

          validate
        end
      end

      context 'when an incomplete employment income payment exists' do
        let(:partner_employment_income) { instance_double(Payment, complete?: false) }

        it 'adds an error to :employment_income' do
          expect(errors).to receive(:add).with(:employment_income, :incomplete)

          validate
        end
      end

      context 'when an employment income payment exists and is complete' do
        let(:partner_employment_income) { instance_double(Payment, complete?: true) }

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate_self_assessment_tax_bill' do
    subject(:validate) { validator.validate_self_assessment_tax_bill }

    context 'when partner_self_assessment_tax_bill is blank' do
      let(:partner_self_assessment_tax_bill) { nil }

      it 'adds an error to :self_assessment_tax_bill' do
        expect(errors).to receive(:add).with(:partner_self_assessment_tax_bill, :incomplete)

        validate
      end
    end

    context 'when partner_self_assessment_tax_bill is yes' do
      let(:partner_self_assessment_tax_bill) { 'yes' }

      context 'when partner_self_assessment_tax_bill_amount is not present' do
        let(:partner_self_assessment_tax_bill_amount) { nil }
        let(:partner_self_assessment_tax_bill_frequency) { 'week' }

        it 'adds an error to :self_assessment_tax_bill' do
          expect(errors).to receive(:add).with(:partner_self_assessment_tax_bill, :incomplete)

          validate
        end
      end

      context 'when partner_self_assessment_tax_bill_frequency is not present' do
        let(:partner_self_assessment_tax_bill_amount) { 150.0 }
        let(:partner_self_assessment_tax_bill_frequency) { nil }

        it 'adds an error to :self_assessment_tax_bill' do
          expect(errors).to receive(:add).with(:partner_self_assessment_tax_bill, :incomplete)

          validate
        end
      end

      context 'when partner_self_assessment_tax_bill fields are complete' do
        let(:partner_self_assessment_tax_bill_amount) { 150.0 }
        let(:partner_self_assessment_tax_bill_frequency) { 'week' }

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate_other_work_benefit' do
    subject(:validate) { validator.validate_other_work_benefit }

    context 'when partner_other_work_benefit_received is blank' do
      let(:partner_other_work_benefit_received) { nil }

      it 'adds an error to :applicant_other_work_benefit_received' do
        expect(errors).to receive(:add).with(:partner_other_work_benefit_received, :incomplete)

        validate
      end
    end

    context 'when partner_other_work_benefit_received is yes' do
      let(:partner_other_work_benefit_received) { 'yes' }

      context 'when there is no work_benefit payment' do
        before do
          allow(record).to receive(:partner_work_benefits).and_return(nil)
        end

        it 'adds an error to :partner_other_work_benefit_received' do
          expect(errors).to receive(:add).with(:partner_other_work_benefit_received, :incomplete)

          validate
        end
      end

      context 'when work_benefit payment exists but is not complete' do
        before do
          allow(record).to receive(:partner_work_benefits) { instance_double(Payment, complete?: false) }
        end

        it 'adds an error to :partner_other_work_benefit_received' do
          expect(errors).to receive(:add).with(:partner_other_work_benefit_received, :incomplete)

          validate
        end
      end

      context 'when partner_other_work_benefit_received payment is complete' do
        before do
          allow(record).to receive(:partner_work_benefits) { instance_double(Payment, complete?: true) }
        end

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate_partner_self_employment' do
    subject(:validate) { validator.validate_partner_self_employment }

    before do
      allow(record).to receive(:partner_self_employed?).and_return(true)
    end

    context 'when partner is self employed' do
      let(:partner_employment_status) { [EmploymentStatus::SELF_EMPLOYED.to_s] }
      let(:partner_other_work_benefit_received) { 'no' }
      let(:partner_self_assessment_tax_bill) { 'no' }

      context 'when there are no businesses' do
        it 'adds an error to :businesses' do
          expect(errors).to receive(:add).with(:businesses, :incomplete)

          validate
        end
      end

      context 'where there is an incomplete business' do
        let(:partner_businesses) { [instance_double(Business, complete?: false)] }

        it 'adds an error to :businesses' do
          expect(errors).to receive(:add).with(:businesses, :incomplete)

          validate
        end
      end

      context 'when businesses are complete' do
        let(:partner_businesses) { [instance_double(Business, complete?: true)] }

        it 'adds an error to :businesses' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate' do
    subject(:validate) { validator.validate }

    before do
      allow(MeansStatus).to receive(:full_means_required?).and_return(true)
    end

    context 'when not applicable' do
      before do
        allow(validator).to receive(:applicable?).and_return(false)
      end

      it 'does not add errors' do
        expect(errors).not_to receive(:add)
        validate
      end
    end

    context 'when not working' do
      let(:partner_employment_status) { [] }

      before do
        allow(validator).to receive(:applicable?).and_return(true)
        allow(record).to receive_messages(partner_employed?: false, partner_self_employed?: false)
      end

      it 'adds errors to :employment_status when incomplete' do
        expect(errors).to receive(:add).with(:partner_employment_status, :incomplete)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        validate
      end
    end
  end

  describe '#validate_armed_forces' do
    subject(:validate) { validator.validate_armed_forces }

    context 'when partner_in_armed_forces is required' do
      before { allow(record).to receive(:require_partner_in_armed_forces?).and_return(true) }

      context 'and partner_in_armed_forces is nil' do
        let(:partner_in_armed_forces) { nil }

        it 'adds errors to :partner_in_armed_forces' do
          expect(errors).to receive(:add).with(:partner_in_armed_forces, :incomplete)

          validate
        end
      end

      context 'and partner_in_armed_forces is not nil' do
        let(:partner_in_armed_forces) { 'yes' }

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end

    context 'when partner_in_armed_forces is not required' do
      before { allow(record).to receive(:require_partner_in_armed_forces?).and_return(false) }

      it 'does not add errors' do
        expect(errors).not_to receive(:add)

        validate
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
