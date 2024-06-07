require 'rails_helper'

RSpec.describe Applicant, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) { {} }

  describe '#has_passporting_benefit' do
    context 'when `benefit_type` is Universal Credit' do
      let(:attributes) { { benefit_type: 'universal_credit' } }

      it 'returns true' do
        expect(subject.has_passporting_benefit?).to be true
      end
    end

    context 'when `benefit_type` is invalid' do
      let(:attributes) { { benefit_type: 'invalid_benefit_type' } }

      it 'returns false' do
        expect(subject.has_passporting_benefit?).to be false
      end
    end

    context 'when `benefit_type` is none' do
      let(:attributes) { { benefit_type: 'none' } }

      it 'returns false' do
        expect(subject.has_passporting_benefit?).to be false
      end
    end
  end

  describe 'has partnership information' do
    let(:partner_detail) do
      PartnerDetail.new(
        has_partner: 'yes',
        relationship_status: 'separated',
        separation_date: Date.new(1991, 8, 7),
      )
    end

    let(:attributes) do
      {
        crime_application: CrimeApplication.new(partner_detail:)
      }
    end

    it 'has_partner' do
      expect(subject.has_partner).to eq 'yes'
    end

    it 'relationship_status' do
      expect(subject.relationship_status).to eq 'separated'
    end

    it 'separation_date' do
      expect(subject.separation_date).to eq Date.new(1991, 8, 7)
    end
  end
end
