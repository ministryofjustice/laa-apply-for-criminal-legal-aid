require 'rails_helper'

RSpec.describe Evidence::Rules::SavingsCerts do
  subject(:rule) { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      national_savings_certificates: national_savings_certificates,
      partner: Partner.new,
      applicant: Applicant.new
    )
  end
  let(:national_savings_certificates) { [] }

  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?).with(crime_application) { include_partner? }
  end

  it { expect(described_class.key).to eq :capital_savings_certs_22 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject(:client) { rule.client_predicate }

    context 'when none' do
      it { is_expected.to be false }
    end

    context 'when owned by applicant' do
      let(:national_savings_certificates) do
        [NationalSavingsCertificate.new(ownership_type: 'applicant')]
      end

      it { is_expected.to be true }
    end

    context 'when owned by partner' do
      let(:national_savings_certificates) do
        [NationalSavingsCertificate.new(ownership_type: 'partner')]
      end

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:partner) { rule.partner_predicate }

    context 'when none' do
      it { is_expected.to be false }
    end

    context 'when owned by applicant' do
      let(:national_savings_certificates) do
        [NationalSavingsCertificate.new(ownership_type: 'applicant')]
      end

      it { is_expected.to be false }
    end

    context 'when owned by partner' do
      let(:national_savings_certificates) do
        [NationalSavingsCertificate.new(ownership_type: 'partner')]
      end

      it { is_expected.to be true }

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:national_savings_certificates) do
      [NationalSavingsCertificate.new(ownership_type: 'applicant')]
    end

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
