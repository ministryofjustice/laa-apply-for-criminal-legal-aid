require 'rails_helper'

RSpec.describe Evidence::Rules::BenefitsInKind do
  subject { described_class.new(crime_application) }

  # A double may not always be appropriate for testing,
  # consider using real objects
  let(:crime_application) do
    instance_double(
      CrimeApplication, partner: double, applicant: double
    )
  end

  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?).with(crime_application) { include_partner? }
  end

  it { expect(described_class.key).to eq :income_noncash_benefit_4 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    it { expect(subject.client_predicate).to be false }
  end

  describe '.partner' do
    it { expect(subject.partner_predicate).to be false }
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h', skip: 'Awaiting benefit in kind implementation' do
    let(:expected_hash) do
      {
        id: 'BenefitsInKind',
        group: :income,
        ruleset: nil,
        key: :income_noncash_benefit_4,
        run: {
          client: {
            result: true,
            prompt: ["their P11D form for 'benefits in kind'"],
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

    it { expect(subject.to_h).to eq expected_hash }
  end
end
