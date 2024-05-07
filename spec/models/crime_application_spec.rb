require 'rails_helper'

RSpec.describe CrimeApplication, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) { {} }

  describe 'status enum' do
    it 'has the right values' do
      expect(
        described_class.statuses
      ).to eq(
        'in_progress' => 'in_progress',
      )
    end
  end

  describe '#not_means_tested?' do
    context 'when application is not means tested' do
      let(:attributes) { { is_means_tested: 'no' } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(true)
      end
    end

    context 'when application is means tested' do
      let(:attributes) { { is_means_tested: 'yes' } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(false)
      end
    end

    context 'when is means tested is nil' do
      let(:attributes) { { is_means_tested: nil } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(false)
      end
    end
  end

  describe 'evidence' do
    it 'has an initial empty prompts' do
      expect(subject.evidence_prompts).to eq []
    end

    it 'has no evidence last run at' do
      expect(subject.evidence_last_run_at).to be_nil
    end
  end

  it 'has an initial status value of "in_progress"' do
    expect(subject.status).to eq('in_progress')
  end

  describe '#applicant_18_or_over_at_date_stamp' do
    let(:applicant) { nil }
    let(:attributes) {
      {
        applicant: applicant,
        date_stamp: DateTime.now
      }
    }

    context 'when the applicant is over 18' do
      let(:applicant) { Applicant.new(date_of_birth: Date.new(1994, 5, 12)) }

      it 'returns true' do
        expect(subject.applicant_18_or_over_at_date_stamp?).to be true
      end
    end

    context 'when the applicant is under 18' do
      let(:applicant) { Applicant.new(date_of_birth: Date.new(2015, 5, 12)) }

      it 'returns false' do
        expect(subject.applicant_18_or_over_at_date_stamp?).to be false
      end
    end

    context 'when there is no date stamp' do
      let(:applicant) { Applicant.new(date_of_birth: Date.new(1994, 5, 12)) }

      it 'calls the `under18?` method' do
        expect(subject.applicant_18_or_over_at_date_stamp?).to be true
      end
    end
  end

  describe '#applicant_requires_nino_evidence?' do
    let(:nino) { nil }
    let(:dob) { nil }
    let(:applicant) { Applicant.new(date_of_birth: dob, nino: nino) }
    let(:attributes) {
      {
        applicant: applicant,
        date_stamp: DateTime.now
      }
    }

    context 'when the applicant is under 18' do
      let(:dob) { Date.new(2015, 5, 12) }

      it 'returns false' do
        expect(subject.applicant_requires_nino_evidence?).to be false
      end
    end

    context 'when a NINO has been entered' do
      let(:dob) { Date.new(1995, 5, 12) }
      let(:nino) { 'AB123456A' }

      it 'returns false' do
        expect(subject.applicant_requires_nino_evidence?).to be false
      end
    end

    context 'when the applicant is over 18 and no NINO is present' do
      let(:benefit_type) { nil }
      let(:applicant) {
        Applicant.new(
          date_of_birth: Date.new(1995, 5, 12),
          nino: nil,
          benefit_type: benefit_type,
        )
      }
      let(:case_type) { nil }
      let(:kase) { Case.new(case_type:) }
      let(:income_benefits) { [] }
      let(:attributes) {
        {
          applicant: applicant,
          case: kase,
          date_stamp: DateTime.now,
          income_benefits: income_benefits,
        }
      }

      context 'when the case type is `indictable`' do
        let(:case_type) { CaseType::INDICTABLE.to_s }

        it 'returns true' do
          expect(subject.applicant_requires_nino_evidence?).to be true
        end
      end

      context 'when the case type is `already_in_crown_court`' do
        let(:case_type) { CaseType::ALREADY_IN_CROWN_COURT.to_s }

        it 'returns true' do
          expect(subject.applicant_requires_nino_evidence?).to be true
        end
      end

      context 'when the applicant receives a passporting benefit' do
        let(:benefit_type) { 'universal_credit' }

        it 'returns true' do
          expect(subject.applicant_requires_nino_evidence?).to be true
        end
      end

      context 'when the applicant receives a non-passporting benefit' do
        let(:income_benefits) { [IncomeBenefit.new(payment_type: IncomeBenefitType::CHILD, amount: 200)] }

        it 'returns true' do
          expect(subject.applicant_requires_nino_evidence?).to be true
        end
      end

      context 'when none of these conditions are met' do
        let(:case_type) { CaseType::EITHER_WAY.to_s }
        let(:benefit_type) { nil }
        let(:income_benefits) { [] }

        it 'returns false' do
          expect(subject.applicant_requires_nino_evidence?).to be false
        end
      end
    end
  end

  describe '#passporting_benefit_complete?' do
    # Validation tested in validator spec
    let(:benefit_type) { nil }
    let(:applicant) { Applicant.new(benefit_type:) }
    let(:attributes) { { applicant: } }

    it 'returns false' do
      expect(subject.passporting_benefit_complete?).to be false
    end
  end
end
