require 'rails_helper'

RSpec.describe Evidence::Rules::SavingsCerts do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      capital:
    )
  end

  let(:capital) { Capital.new }

  it { expect(described_class.key).to eq :capital_savings_certs_22 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with national savings certificates saving' do
      let(:capital) { Capital.new(has_national_savings_certificates: 'yes') }

      it { is_expected.to be true }
    end

    context 'without national savings certificates saving' do
      let(:capital) { Capital.new(has_national_savings_certificates: 'no') }

      it { is_expected.to be false }
    end

    context 'when national savings certificates saving is not set' do
      let(:capital) { Capital.new(has_national_savings_certificates: nil) }

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
    let(:capital) { Capital.new(has_national_savings_certificates: 'yes') }

    let(:expected_hash) do
      {
        id: 'SavingsCerts',
        group: :capital,
        ruleset: nil,
        key: :capital_savings_certs_22,
        run: {
          client: {
            result: true,
            prompt: ['the National Savings Certificates or passbook'],
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
