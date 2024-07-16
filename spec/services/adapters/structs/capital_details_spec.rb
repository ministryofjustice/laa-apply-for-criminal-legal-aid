require 'rails_helper'

RSpec.describe Adapters::Structs::CapitalDetails do
  subject(:adapter) { application_struct.capital }

  let(:application_struct) { build_struct_application }

  describe '#savings' do
    it 'returns a savings collection' do
      expect(subject.savings).to all(be_an(Saving))
    end
  end

  describe '#investments' do
    it 'returns a investments collection' do
      expect(subject.investments).to all(be_an(Investment))
    end
  end

  describe '#national_savings_certificates' do
    it 'returns a national_savings_certificates collection' do
      expect(subject.national_savings_certificates).to all(be_an(NationalSavingsCertificate))
    end
  end

  describe '#properties' do
    it 'returns a properties collection' do
      expect(subject.properties).to all(be_an(Property))
    end
  end

  describe '#trust_fund_amount_held' do
    subject(:trust_fund_amount_held) { adapter.trust_fund_amount_held }

    it { is_expected.to be_a Money }
    it { is_expected.to eq 100_000 }
  end

  describe '#trust_fund_yearly_dividend' do
    subject(:trust_fund_yearly_dividend) { adapter.trust_fund_yearly_dividend }

    it { is_expected.to be_a Money }
    it { is_expected.to eq 200_000 }
  end

  describe '#premium_bonds_total_value' do
    subject(:premium_bonds_total_value) { adapter.premium_bonds_total_value }

    it { is_expected.to be_a Money }
    it { is_expected.to eq 100_000 }
  end

  describe '#partner_premium_bonds_total_value' do
    subject(:partner_premium_bonds_total_value) { adapter.partner_premium_bonds_total_value }

    it { is_expected.to be_a Money }
    it { expect(subject.value).to be_nil }
  end

  describe '#partner_trust_fund_yearly_dividend' do
    subject(:partner_trust_fund_yearly_dividend) { adapter.partner_trust_fund_yearly_dividend }

    it { is_expected.to be_a Money }
    it { expect(subject.value).to be_nil }
  end

  describe '#partner_trust_fund_amount_held' do
    subject(:partner_trust_fund_amount_held) { adapter.partner_trust_fund_amount_held }

    it { is_expected.to be_a Money }
    it { expect(subject.value).to be_nil }
  end

  describe '#serializable_hash' do
    it 'returns a serializable hash, including relationships' do
      expect(
        subject.serializable_hash
      ).to match(
        a_hash_including(
          'has_frozen_income_or_assets' => nil,
          'has_no_other_assets' => 'yes',
          'has_premium_bonds' => 'yes',
          'premium_bonds_holder_number' => '123568A',
          'premium_bonds_total_value' => 100_000,
          'trust_fund_amount_held' => 100_000,
          'trust_fund_yearly_dividend' => 200_000,
          'will_benefit_from_trust_fund' => 'yes',
        )
      )
    end

    # rubocop:disable RSpec/ExampleLength
    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          has_frozen_income_or_assets
          has_no_other_assets
          has_premium_bonds
          premium_bonds_total_value
          premium_bonds_holder_number
          trust_fund_amount_held
          trust_fund_yearly_dividend
          will_benefit_from_trust_fund
          partner_has_premium_bonds
          partner_premium_bonds_total_value
          partner_premium_bonds_holder_number
          partner_trust_fund_yearly_dividend
          partner_trust_fund_amount_held
          partner_will_benefit_from_trust_fund
        ]
      )
    end
    # rubocop:enable RSpec/ExampleLength

    it 'omits savings array' do
      expect(subject.serializable_hash.key?('savings')).to be false
      expect(subject.serializable_hash.key?('investments')).to be false
      expect(subject.serializable_hash.key?('national_savings_certificates')).to be false
      expect(subject.serializable_hash.key?('properties')).to be false
    end
  end
end
