require 'rails_helper'

RSpec.describe Evidence::Rules::BuildingSocietyAccounts do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      savings:
    )
  end

  let(:savings) { [] }

  it { expect(described_class.key).to eq :capital_building_society_accounts_17 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with 1 building society account' do
      let(:savings) { [Saving.new(saving_type: 'building_society', ownership_type: :applicant)] }

      it { is_expected.to be true }
    end

    context 'with 2 building society accounts' do
      let(:savings) do
        [
          Saving.new(saving_type: 'building_society', ownership_type: :applicant),
          Saving.new(saving_type: 'building_society', ownership_type: :applicant),
        ]
      end

      it { is_expected.to be true }
    end

    context 'without building_society accounts' do
      let(:savings) { [Saving.new(saving_type: 'other', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end

    context 'when not owned by client' do
      let(:savings) { [Saving.new(saving_type: 'building_society', ownership_type: :partner)] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'with 1 building society account' do
      let(:savings) { [Saving.new(saving_type: 'building_society', ownership_type: :partner)] }

      it { is_expected.to be true }
    end

    context 'with 2 building society accounts' do
      let(:savings) do
        [
          Saving.new(saving_type: 'building_society', ownership_type: :partner),
          Saving.new(saving_type: 'building_society', ownership_type: :partner),
        ]
      end

      it { is_expected.to be true }
    end

    context 'without building_society accounts' do
      let(:savings) { [Saving.new(saving_type: 'other', ownership_type: :partner)] }

      it { is_expected.to be false }
    end

    context 'when not owned by partner' do
      let(:savings) { [Saving.new(saving_type: 'building_society', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:savings) do
      [
        Saving.new(saving_type: 'building_society', ownership_type: :applicant),
        Saving.new(saving_type: 'building_society', ownership_type: :partner),
      ]
    end

    # rubocop:disable Layout/LineLength
    let(:expected_hash) do
      {
        id: 'BuildingSocietyAccounts',
        group: :capital,
        ruleset: nil,
        key: :capital_building_society_accounts_17,
        run: {
          client: {
            result: true,
            prompt: ['building society statement or passbook showing transactions for the last 3 months, for each account'],
          },
          partner: {
            result: true,
            prompt: ['building society statement or passbook showing transactions for the last 3 months, for each account'],
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