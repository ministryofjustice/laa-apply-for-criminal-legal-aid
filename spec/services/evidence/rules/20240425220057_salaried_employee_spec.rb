require 'rails_helper'

RSpec.describe Evidence::Rules::SalariedEmployee do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  it { expect(described_class.key).to eq :income_employed_0a }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when employed' do
      let(:client_employed?) { true }

      it { is_expected.to be true }
    end

    context 'when not employed' do
      let(:client_employed?) { false }

      it { is_expected.to be false }
    end

    context 'when there is no income' do
      before do
        crime_application.income = nil
      end

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'when employed' do
      let(:partner_employed?) { true }

      it { is_expected.to be true }

      context 'when partner not included in means' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'when not employed' do
      let(:partner_employed?) { false }

      it { is_expected.to be false }
    end

    context 'when there is no income' do
      before do
        crime_application.income = nil
      end

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:client_employed?) { true }
    let(:partner_employed?) { true }

    let(:expected_hash) do
      {
        id: 'SalariedEmployee',
        group: :income,
        ruleset: nil,
        key: :income_employed_0a,
        run: {
          client: {
            result: true,
            prompt: ["wage slips, salary advice, or a letter from their employer if they're paid by cash"],
          },
          partner: {
            result: true,
            prompt: ["wage slips, salary advice, or a letter from their employer if they're paid by cash"],
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
