require 'rails_helper'

RSpec.describe PassportingBenefit::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(CrimeApplication, errors:, applicant:, kase:, confirm_dwp_result:) }
  let(:errors) { double(:errors, empty?: false) }
  let(:applicant) {
    instance_double(Applicant, benefit_type:, has_benefit_evidence:, has_nino:, will_enter_nino:, passporting_benefit:)
  }
  let(:kase) { instance_double(Case) }
  let(:benefit_type) { nil }
  let(:has_benefit_evidence) { nil }
  let(:has_nino) { nil }
  let(:will_enter_nino) { nil }
  let(:confirm_dwp_result) { nil }
  let(:passporting_benefit) { nil }

  describe '#validate' do
    context 'when validation fails' do
      context 'when section has not been started' do
        it 'adds errors for all failed validations' do
          expect(errors).to receive(:add).with(:benefit_type, :blank)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end

      context 'when applicant has benefit but no nino' do
        let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT }
        let(:has_nino) { 'no' }

        it 'adds errors for all failed validations' do
          expect(errors).to receive(:add).with(:will_enter_nino, :blank)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end

      context 'when dwp check result is no or undetermined' do
        let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT }
        let(:has_nino) { 'yes' }
        let(:passporting_benefit) { false }

        context 'when confirm dwp result is blank' do
          it 'adds errors for all failed validations' do
            expect(errors).to receive(:add).with(:confirm_dwp_result, :blank)
            expect(errors).to receive(:add).with(:base, :incomplete_records)

            subject.validate
          end
        end

        context 'when result is contested' do
          let(:confirm_dwp_result) { 'no' }

          it 'adds errors for all failed validations' do
            expect(errors).to receive(:add).with(:has_benefit_evidence, :blank)
            expect(errors).to receive(:add).with(:base, :incomplete_records)

            subject.validate
          end
        end
      end
    end

    describe '#benefit_type_complete?' do
      context 'when benefit_type present' do
        let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT }

        it 'returns true' do
          expect(subject.benefit_type_complete?).to be(true)
        end
      end

      context 'when benefit_type not present' do
        it 'returns false' do
          expect(subject.benefit_type_complete?).to be(false)
        end
      end
    end

    describe '#will_enter_nino_complete?' do
      let(:has_nino) { 'no' }

      context 'when will enter nino present' do
        let(:will_enter_nino) { 'no' }

        it 'returns true' do
          expect(subject.will_enter_nino_complete?).to be(true)
        end
      end

      context 'when will_enter_nino not present' do
        it 'returns false' do
          expect(subject.will_enter_nino_complete?).to be(false)
        end
      end
    end

    describe '#confirm_dwp_result_complete?' do
      context 'when applicant does not have nino' do
        let(:has_nino) { 'no' }

        it 'returns true' do
          expect(subject.confirm_dwp_result_complete?).to be(true)
        end
      end

      context 'when applicant does have nino' do
        let(:has_nino) { 'yes' }

        context 'when confirm_dwp_result is present' do
          let(:confirm_dwp_result) { 'no' }

          it 'returns true' do
            expect(subject.confirm_dwp_result_complete?).to be(true)
          end
        end

        context 'when confirm_dwp_result not present' do
          it 'returns false' do
            expect(subject.confirm_dwp_result_complete?).to be(false)
          end
        end
      end
    end

    describe '#has_benefit_evidence_complete?' do
      context 'when applicant confirms dwp result' do
        let(:confirm_dwp_result) { 'yes' }

        it 'returns true' do
          expect(subject.has_benefit_evidence_complete?).to be(true)
        end
      end

      context 'when applicant contests dwp result' do
        let(:confirm_dwp_result) { 'no' }

        context 'when has_benefit_evidence is present' do
          let(:has_benefit_evidence) { 'yes' }

          it 'returns true' do
            expect(subject.has_benefit_evidence_complete?).to be(true)
          end
        end

        context 'when has_benefit_evidence not present' do
          it 'returns false' do
            expect(subject.has_benefit_evidence_complete?).to be(false)
          end
        end
      end
    end

    describe '#dwp_check_not_undertaken?' do
      context 'when passporting_benefit present' do
        let(:passporting_benefit) { false }

        it 'returns false' do
          expect(subject.dwp_check_not_undertaken?).to be(false)
        end
      end

      context 'when passporting_benefit not present' do
        it 'returns true' do
          expect(subject.dwp_check_not_undertaken?).to be(true)
        end
      end
    end
  end
end
