require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe DWP::BenefitCheckStatusService do
  subject { described_class.new(crime_application, applicant) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      confirm_dwp_result: confirm_dwp_result,
      applicant: applicant
    )
  end

  let(:applicant) do
    double(
      Applicant,
      benefit_type:,
      last_jsa_appointment_date:,
      benefit_check_result:,
      has_nino:,
      nino:,
      will_enter_nino:,
      confirm_details:,
      has_benefit_evidence:
    )
  end

  let(:benefit_type) { nil }
  let(:last_jsa_appointment_date) { nil }
  let(:has_nino) { nil }
  let(:nino) { nil }
  let(:will_enter_nino) { nil }
  let(:benefit_check_result) { nil }
  let(:confirm_details) { nil }
  let(:has_benefit_evidence) { nil }
  let(:confirm_dwp_result) { nil }

  describe '#call' do
    context 'when benefit check outcome undetermined' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:has_nino) { YesNoAnswer::YES.to_s }
      let(:nino) { '123456' }
      let(:benefit_check_result) { false }
      let(:confirm_details) { YesNoAnswer::YES.to_s }
      let(:confirm_dwp_result) { YesNoAnswer::NO.to_s }

      context 'and has benefit evidence is yes' do
        let(:has_benefit_evidence) { YesNoAnswer::YES.to_s }

        it 'returns a benefit check status of undetermined' do
          expect(subject.call).to eq('undetermined')
        end
      end

      context 'and has benefit evidence is no' do
        let(:has_benefit_evidence) { YesNoAnswer::NO.to_s }

        it 'returns a benefit check status of no_record_found' do
          expect(subject.call).to eq('no_record_found')
        end
      end
    end

    context 'when applicant benefit has been confirmed by benefit checker' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:benefit_check_result) { true }

      it 'returns a benefit check status of confirmed' do
        expect(subject.call).to eq('confirmed')
      end
    end

    context 'when benefit check not required' do
      let(:benefit_type) { 'none' }

      it 'returns a benefit check status of no_check_required' do
        expect(subject.call).to eq('no_check_required')
      end
    end

    context 'when benefit checker unavailable' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:has_benefit_evidence) { YesNoAnswer::YES.to_s }

      it 'returns a benefit check status of checker_unavailable' do
        expect(subject.call).to eq('checker_unavailable')
      end
    end

    context 'when nino forthcoming' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:has_nino) { YesNoAnswer::NO.to_s }
      let(:will_enter_nino) { YesNoAnswer::NO.to_s }
      let(:benefit_check_status) { 'no_check_no_nino' }

      it 'returns a benefit check status of no_check_no_nino' do
        expect(subject.call).to eq('no_check_no_nino')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
