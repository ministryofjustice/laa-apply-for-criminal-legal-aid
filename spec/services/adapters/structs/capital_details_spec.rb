require 'rails_helper'

RSpec.describe Adapters::Structs::CapitalDetails do
  subject { application_struct.capital }

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
        ]
      )
    end

    it 'omits savings array' do
      expect(subject.serializable_hash.key?('savings')).to be false
      expect(subject.serializable_hash.key?('investments')).to be false
      expect(subject.serializable_hash.key?('national_savings_certificates')).to be false
      expect(subject.serializable_hash.key?('properties')).to be false
    end
  end
end
