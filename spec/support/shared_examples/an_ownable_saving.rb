RSpec.shared_examples 'an ownable saving requiring evidence' do
  subject(:rule) { described_class.new(crime_application) }

  include_context 'serializable application'

  let(:include_partner?) { true }
  let(:full_capital_required?) { true }
  let(:savings) { [] }

  describe '.client' do
    subject(:predicate) { described_class.new(crime_application).client_predicate }

    let(:ownership_type) { OwnershipType::APPLICANT }

    let(:savings) do
      [Saving.new(saving_type: saving_type, ownership_type: ownership_type, account_balance: 101)]
    end

    context 'when owned by client' do
      it { is_expected.to be true }
    end

    context 'when capital section not answered' do
      let(:age_passported?) { true }

      it { is_expected.to be false }
    end

    context 'when full capital is not required' do
      let(:full_capital_required?) { false }

      it { is_expected.to be false }
    end

    context 'when jointly owned' do
      let(:ownership_type) { OwnershipType::APPLICANT_AND_PARTNER }

      it { is_expected.to be true }
    end

    context 'with a different saving type' do
      let(:saving_type) { SavingType.values.find { |st| st != SavingType.new(super().to_sym) } }

      it { is_expected.to be false }
    end

    context 'when owned by partner' do
      let(:ownership_type) { OwnershipType::PARTNER }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { described_class.new(crime_application).partner_predicate }

    let(:ownership_type) { OwnershipType::PARTNER }

    let(:savings) do
      [Saving.new(saving_type: saving_type, ownership_type: ownership_type, account_balance: 101)]
    end

    context 'when capital section not answered' do
      let(:age_passported?) { true }

      it { is_expected.to be false }
    end

    context 'when owned by partner' do
      it { is_expected.to be true }

      context 'when full capital is not required' do
        let(:full_capital_required?) { false }

        it { is_expected.to be false }
      end

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'when jointly owned' do
      let(:ownership_type) { OwnershipType::APPLICANT_AND_PARTNER }

      it { is_expected.to be true }
    end

    context 'with a different saving type' do
      let(:saving_type) { SavingType.values.find { |st| st != SavingType.new(super().to_sym) } }

      it { is_expected.to be false }
    end

    context 'when owned by client' do
      let(:ownership_type) { OwnershipType::APPLICANT }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:savings) do
      [
        Saving.new(saving_type: saving_type, ownership_type: :applicant, account_balance: 123),
        Saving.new(saving_type: saving_type, ownership_type: :partner, account_balance: 4234)
      ]
    end

    let(:expected_hash) do
      {
        id: described_class.name.demodulize,
        group: described_class.group,
        ruleset: nil,
        key: described_class.key,
        run: {
          client: {
            result: true,
            prompt: [expected_client_prompt]
          },
          partner: {
            result: true,
            prompt: [expected_partner_prompt]
          },
          other: {
            result: false,
            prompt: [],
          },
        }
      }
    end

    it { expect(rule.to_h).to eq expected_hash }
  end
end
