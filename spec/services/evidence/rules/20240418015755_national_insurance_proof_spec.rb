require 'rails_helper'

RSpec.describe Evidence::Rules::NationalInsuranceProof do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant:,
    )
  end

  let(:expected_hash) do
    {
      id: 'NationalInsuranceProof',
      group: :none,
      ruleset: nil,
      key: :national_insurance_32,
      run: {
        client: {
          result: false,
          prompt: [],
        },
        partner: {
          result: false,
          prompt: [],
        },
        other: {
          result: true,
          prompt: ['their National Insurance number'],
        },
      }
    }
  end

  it { expect(described_class.key).to eq :national_insurance_32 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    it { expect(described_class.client).to be_nil }
  end

  describe '.partner' do
    it { expect(described_class.partner).to be_nil }
  end

  describe '.other' do
    context 'when applicant has nino' do
      let(:applicant) { instance_double(Applicant, has_nino: 'yes') }

      it { expect(subject.other_predicate).to be true }
      it { expect(subject.to_h).to eq expected_hash }
    end

    context 'when applicant does not have nino' do
      let(:applicant) { instance_double(Applicant, has_nino: 'no') }

      it { expect(subject.other_predicate).to be false }
    end
  end
end
