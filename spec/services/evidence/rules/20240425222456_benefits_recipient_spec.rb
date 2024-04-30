require 'rails_helper'

RSpec.describe Evidence::Rules::BenefitsRecipient do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      applicant:
    )
  end

  let(:applicant) { Applicant.new }

  it { expect(described_class.key).to eq :income_benefits_0b }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when they have passported benefit but failed DWP check' do
      let(:applicant) do
        Applicant.new(has_benefit_evidence: 'yes', benefit_type: 'jsa', passporting_benefit: false)
      end

      it { is_expected.to be true }
    end

    context 'when they have passported benefit but passed DWP check' do
      let(:applicant) do
        Applicant.new(has_benefit_evidence: 'yes', benefit_type: 'jsa', passporting_benefit: true)
      end

      it { is_expected.to be false }
    end

    context 'when they have passported benefit but non-passported benefit type' do
      let(:applicant) do
        Applicant.new(has_benefit_evidence: 'yes', benefit_type: 'none', passporting_benefit: nil)
      end

      it { is_expected.to be false }
    end

    context 'when they have no benefit evidence' do
      let(:applicant) do
        Applicant.new(has_benefit_evidence: nil)
      end

      it { is_expected.to be false }
    end

    context 'when there is no applicant' do
      let(:applicant) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    it { expect(subject.partner_predicate).to be false }
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:applicant) do
      Applicant.new(has_benefit_evidence: 'yes', benefit_type: 'jsa', passporting_benefit: false)
    end

    # rubocop:disable Layout/LineLength
    let(:expected_hash) do
      {
        id: 'BenefitsRecipient',
        group: :income,
        ruleset: nil,
        key: :income_benefits_0b,
        run: {
          client: {
            result: true,
            prompt: ['benefit book or notice of entitlement or letter from Jobcentre Plus stating the benefits your client receives'],
          },
          partner: {
            result: false,
            prompt: [],
          },
          other: {
            result: false,
            prompt: [],
          },
        }
      }
    end
    # rubocop:enable Layout/LineLength

    it { expect(subject.to_h).to eq expected_hash }
  end
end
