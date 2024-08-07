require 'rails_helper'

RSpec.describe Evidence::Rules::RestraintOrFreezingOrder do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  it { expect(described_class.key).to eq :restraint_freezing_order_31 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'means passported' do
      let(:age_passported?) { true }

      it { is_expected.to be false }
    end

    context 'when client does not have a restraining or freezing order in place' do
      context 'when question was not answered in the capital section' do
        before { capital.has_frozen_income_or_assets = 'no' }

        it { is_expected.to be false }
      end

      context 'when question was not answered in the income section' do
        before { income.has_frozen_income_or_assets = 'no' }

        it { is_expected.to be false }
      end
    end

    context 'when client has a restraining or freezing order in place' do
      context 'when question was answered in the capital section' do
        before { capital.has_frozen_income_or_assets = 'yes' }

        it { is_expected.to be true }
      end

      context 'when question was answered in the income section' do
        before do
          capital.has_frozen_income_or_assets = nil
          income.has_frozen_income_or_assets = 'yes'
        end

        it { is_expected.to be true }
      end
    end

    context 'when there is no capital' do
      let(:capital) { nil }

      it { is_expected.to be false }
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
    before { capital.has_frozen_income_or_assets = 'yes' }

    let(:expected_hash) do
      {
        id: 'RestraintOrFreezingOrder',
        group: :none,
        ruleset: nil,
        key: :restraint_freezing_order_31,
        run: {
          client: {
            result: true,
            prompt: ['the restraint or freezing order']
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
