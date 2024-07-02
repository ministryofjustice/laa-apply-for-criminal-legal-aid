require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe EmploymentDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) do
    instance_double(
      Income,
      errors:,
      crime_application:,
      employment_status:,
      employments:,
      partner_employment_status:,
      ended_employment_within_three_months:,
      applicant_self_assessment_tax_bill:,
      applicant_self_assessment_tax_bill_amount:,
      applicant_self_assessment_tax_bill_frequency:,
      applicant_other_work_benefit_received:,
    )
  end

  let(:errors) { double(:errors, empty?: false) }
  let(:crime_application) { instance_double(CrimeApplication, partner_detail:, partner:) }
  let(:employment_status) {
    []
  }
  let(:partner_employment_status) { nil }
  let(:partner_detail) { nil }
  let(:partner) { nil }
  let(:employments) { [] }
  let(:applicant_self_assessment_tax_bill) { nil }
  let(:applicant_self_assessment_tax_bill_amount) { nil }
  let(:applicant_self_assessment_tax_bill_frequency) { nil }
  let(:applicant_other_work_benefit_received) { nil }
  let(:ended_employment_within_three_months) { nil }

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when means assessment required' do
      before do
        allow(validator).to receive(:requires_means_assessment?).and_return(true)
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

  describe '#not_working_details_complete?' do
    subject(:not_working_details_complete?) { validator.not_working_details_complete? }

    context 'when working' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      it { is_expected.to be(true) }
    end

    context 'when not working' do
      let(:employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }
      let(:ended_employment_within_three_months) { 'yes' }
      let(:lost_job_in_custody) { 'yes' }
      let(:date_job_lost) { '2000-01-01' }

      before do
        allow(record).to receive_messages(
          ended_employment_within_three_months:,
          lost_job_in_custody:,
          date_job_lost:
        )
      end

      it { is_expected.to be(true) }

      context 'when lost in custody date is missing' do
        let(:date_job_lost) { nil }

        it { is_expected.to be(false) }
      end

      context 'when ended employment within three months not answered' do
        let(:ended_employment_within_three_months) { nil }

        it { is_expected.to be(false) }
      end

      context 'when not ended employment within last three months' do
        let(:ended_employment_within_three_months) { 'no' }
        let(:lost_job_in_custody) { nil }
        let(:date_job_lost) { nil }

        it { is_expected.to be(true) }
      end
    end
  end

  describe '#validate_employment_details' do
    subject(:validate) { validator.validate_employment_details }

    context 'when does not require a full means assessment' do
      before do
        allow(validator).to receive(:requires_full_means_assessment?).and_return(false)
      end

      it 'does not add errors' do
        expect(errors).not_to receive(:add)

        validate
      end
    end

    context 'when requires a full means assessment' do
      before do
        allow(validator).to receive(:requires_full_means_assessment?).and_return(true)
      end

      context 'when there are no employments' do
        let(:applicant_other_work_benefit_received) { 'no' }
        let(:applicant_self_assessment_tax_bill) { 'no' }
        let(:employments) { [] }

        it 'adds an error to :employments' do
          expect(errors).to receive(:add).with(:employments, :incomplete)

          validate
        end
      end

      context 'where there is an incomplete employment' do
        let(:applicant_other_work_benefit_received) { 'no' }
        let(:applicant_self_assessment_tax_bill) { 'no' }
        let(:employments) { [instance_double(Employment, complete?: false)] }

        it 'adds an error to :employments' do
          expect(errors).to receive(:add).with(:employments, :incomplete)

          validate
        end
      end

      context 'when applicant_other_work_benefit_received is not present' do
        let(:applicant_other_work_benefit_received) { nil }
        let(:applicant_self_assessment_tax_bill) { 'no' }
        let(:employments) { [instance_double(Employment, complete?: true)] }

        it 'adds an error to :other_work_benefit' do
          expect(errors).to receive(:add).with(:applicant_other_work_benefit_received, :incomplete)

          validate
        end
      end

      context 'when all requires attributes are present and complete' do
        let(:applicant_other_work_benefit_received) { 'no' }
        let(:applicant_self_assessment_tax_bill) { 'no' }
        let(:employments) { [instance_double(Employment, complete?: true)] }

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
      end

      context 'when no employment income payment exists' do
        before do
          allow(record).to receive(:client_employment_income).and_return(nil)
        end

        it 'adds an error to :employment_income' do
          expect(errors).to receive(:add).with(:employment_income, :incomplete)

          validate
        end
      end

      context 'when an incomplete employment income payment exists' do
        before do
          allow(record).to receive(:client_employment_income) {
            instance_double(Payment, complete?: false)
          }
        end

        it 'adds an error to :employment_income' do
          expect(errors).to receive(:add).with(:employment_income, :incomplete)

          validate
        end
      end

      context 'when an employment income payment exists and is complete' do
        before do
          allow(record).to receive(:client_employment_income) {
            instance_double(Payment, complete?: true)
          }
        end

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate_self_assessment_tax_bill' do
    subject(:validate) { validator.validate_self_assessment_tax_bill }

    context 'when applicant_self_assessment_tax_bill is blank' do
      let(:applicant_self_assessment_tax_bill) { nil }

      it 'adds an error to :self_assessment_tax_bill' do
        expect(errors).to receive(:add).with(:applicant_self_assessment_tax_bill, :incomplete)

        validate
      end
    end

    context 'when applicant_self_assessment_tax_bill is yes' do
      let(:applicant_self_assessment_tax_bill) { 'yes' }

      context 'when applicant_self_assessment_tax_bill_amount is not present' do
        let(:applicant_self_assessment_tax_bill_amount) { nil }
        let(:applicant_self_assessment_tax_bill_frequency) { 'week' }

        it 'adds an error to :self_assessment_tax_bill' do
          expect(errors).to receive(:add).with(:applicant_self_assessment_tax_bill, :incomplete)

          validate
        end
      end

      context 'when applicant_self_assessment_tax_bill_frequency is not present' do
        let(:applicant_self_assessment_tax_bill_amount) { 150.0 }
        let(:applicant_self_assessment_tax_bill_frequency) { nil }

        it 'adds an error to :self_assessment_tax_bill' do
          expect(errors).to receive(:add).with(:applicant_self_assessment_tax_bill, :incomplete)

          validate
        end
      end

      context 'when applicant_self_assessment_tax_bill fields are complete' do
        let(:applicant_self_assessment_tax_bill_amount) { 150.0 }
        let(:applicant_self_assessment_tax_bill_frequency) { 'week' }

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate_other_work_benefit' do
    subject(:validate) { validator.validate_other_work_benefit }

    before { allow(record).to receive_messages(client_work_benefits:) }

    context 'when applicant_other_work_benefit_received is blank' do
      let(:applicant_other_work_benefit_received) { nil }
      let(:client_work_benefits) { nil }

      it 'adds an error to :applicant_other_work_benefit_received' do
        expect(errors).to receive(:add).with(:applicant_other_work_benefit_received, :incomplete)

        validate
      end
    end

    context 'when applicant_other_work_benefit_received is yes' do
      let(:applicant_other_work_benefit_received) { 'yes' }

      context 'when there is no work_benefit payment' do
        let(:client_work_benefits) { nil }

        it 'adds an error to :applicant_other_work_benefit_received' do
          expect(errors).to receive(:add).with(:applicant_other_work_benefit_received, :incomplete)

          validate
        end
      end

      context 'when work_benefit payment exists but is not complete' do
        let(:client_work_benefits) { instance_double(Payment, complete?: false) }

        it 'adds an error to :applicant_other_work_benefit_received' do
          expect(errors).to receive(:add).with(:applicant_other_work_benefit_received, :incomplete)

          validate
        end
      end

      context 'when applicant_other_work_benefit_received payment is complete' do
        let(:client_work_benefits) { instance_double(Payment, complete?: true) }

        it 'does not add errors' do
          expect(errors).not_to receive(:add)

          validate
        end
      end
    end
  end

  describe '#validate_partner_employment' do
    subject(:validate) { validator.validate_partner_employment }

    context 'when partner employment status is not answered' do
      let(:partner_detail) { double(PartnerDetail, involvement_in_case: 'none') }
      let(:partner_employment_status) { nil }

      it 'adds errors' do
        expect(errors).to receive(:add).with(:partner_employment_status, :incomplete)

        validate
      end
    end

    context 'when partner employment status is answered' do
      let(:partner_employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }

      it 'does not add errors' do
        expect(errors).not_to receive(:add)

        validate
      end
    end
  end

  describe '#validate' do
    subject(:validate) { validator.validate }

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
      let(:employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }

      before do
        allow(validator).to receive(:applicable?).and_return(true)
      end

      it 'adds errors to :employment_status when incomplete' do
        expect(errors).to receive(:add).with(:employment_status, :incomplete)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        validate
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
