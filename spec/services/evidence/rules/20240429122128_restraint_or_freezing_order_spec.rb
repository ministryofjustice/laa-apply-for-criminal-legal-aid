require 'rails_helper'

RSpec.describe Evidence::Rules::RestraintOrFreezingOrder do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      capital: capital, income: income, applicant: Applicant.new, partner: Partner.new
    )
  end

  let(:capital) { Capital.new }
  let(:income) { Income.new }

  before do
    allow(MeansStatus).to receive(:include_partner?).with(crime_application)
                                                    .and_return(true)
  end

  it { expect(described_class.key).to eq :restraint_freezing_order_31 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when client does not have a restraining or freezing order in place' do
      context 'when question was not answered in the capital section' do
        let(:capital) { Capital.new(has_frozen_income_or_assets: 'no') }

        it { is_expected.to be false }
      end

      context 'when question was not answered in the income section' do
        let(:income) { Income.new(has_frozen_income_or_assets: 'no') }

        it { is_expected.to be false }
      end
    end

    context 'when client has a restraining or freezing order in place' do
      context 'when question was answered in the capital section' do
        let(:capital) { Capital.new(has_frozen_income_or_assets: 'yes') }
        let(:income) { Income.new(has_frozen_income_or_assets: nil) }

        it { is_expected.to be true }
      end

      context 'when question was answered in the income section' do
        let(:capital) { Capital.new(has_frozen_income_or_assets: nil) }
        let(:income) { Income.new(has_frozen_income_or_assets: 'yes') }

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
    subject(:predicate) { described_class.new(crime_application).partner_predicate }

    it { is_expected.to be false }

    context 'when question was answered' do
      let(:income) { Income.new(has_frozen_income_or_assets: 'yes') }

      it { is_expected.to be true }
    end
  end

  describe '#to_h' do
    let(:capital) { Capital.new(has_frozen_income_or_assets: 'yes') }

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
            result: true,
            prompt: ['the restraint or freezing order']
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
