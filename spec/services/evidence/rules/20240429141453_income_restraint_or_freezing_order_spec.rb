require 'rails_helper'

RSpec.describe Evidence::Rules::IncomeRestraintOrFreezingOrder do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:
    )
  end

  let(:income) { Income.new }

  it { expect(described_class.key).to eq :income_restraint_freezing_order_31 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when client does not have a restraining or freezing order in place' do
      context 'when question was not answered in the income section' do
        let(:income) { Income.new(has_frozen_income_or_assets: 'no') }

        it { is_expected.to be false }
      end
    end

    context 'when client has a restraining or freezing order in place' do
      context 'when question was answered in the income section' do
        let(:income) { Income.new(has_frozen_income_or_assets: 'yes') }

        it { is_expected.to be true }
      end
    end

    context 'when there is no income' do
      let(:income) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    it { expect(subject.partner_predicate).to be false }
  end

  describe '#to_h' do
    let(:income) { Income.new(has_frozen_income_or_assets: 'yes') }

    let(:expected_hash) do
      {
        id: 'IncomeRestraintOrFreezingOrder',
        group: :income,
        ruleset: nil,
        key: :income_restraint_freezing_order_31,
        run: {
          client: {
            result: true,
            prompt: ['the restraint or freezing order'],
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
