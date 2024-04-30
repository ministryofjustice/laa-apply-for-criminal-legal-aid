require 'rails_helper'

RSpec.describe Evidence::Rules::CashIsa do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      savings:
    )
  end

  let(:savings) { [] }

  it { expect(described_class.key).to eq :capital_cash_isa_18 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with cash isa account' do
      let(:savings) { [Saving.new(saving_type: 'cash_isa', ownership_type: :applicant)] }

      it { is_expected.to be true }
    end

    context 'without cash isa accounts' do
      let(:savings) { [Saving.new(saving_type: 'bank', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end

    context 'when not owned by client' do
      let(:savings) { [Saving.new(saving_type: 'cash_isa', ownership_type: :partner)] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'with cash isa account' do
      let(:savings) { [Saving.new(saving_type: 'cash_isa', ownership_type: :partner)] }

      it { is_expected.to be true }
    end

    context 'without cash isa accounts' do
      let(:savings) { [Saving.new(saving_type: 'bank', ownership_type: :partner)] }

      it { is_expected.to be false }
    end

    context 'when not owned by partner' do
      let(:savings) { [Saving.new(saving_type: 'cash_isa', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:savings) do
      [
        Saving.new(saving_type: 'cash_isa', ownership_type: :applicant),
        Saving.new(saving_type: 'cash_isa', ownership_type: :partner),
      ]
    end

    let(:expected_hash) do
      {
        id: 'CashIsa',
        group: :capital,
        ruleset: nil,
        key: :capital_cash_isa_18,
        run: {
          client: {
            result: true,
            prompt: ['cash ISA statements showing transactions for the last 3 months, for each account'],
          },
          partner: {
            result: true,
            prompt: ['cash ISA statements showing transactions for the last 3 months, for each account'],
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
