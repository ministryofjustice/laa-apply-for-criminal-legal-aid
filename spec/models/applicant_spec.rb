require 'rails_helper'

RSpec.describe Applicant, type: :model do
  subject(:applicant) { described_class.new(attributes) }

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

  describe '#to_param' do
    subject(:to_param) { applicant.to_param }

    it { is_expected.to eq 'client' }
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

  describe 'benefit check reset behaviour' do
    before do
      applicant.confirm_details = 'yes'
      applicant.confirm_dwp_result = 'no'
      applicant.has_benefit_evidence = 'yes'
    end

    context 'when the benefit check result is true' do
      before do
        applicant.benefit_check_result = true
      end

      it { expect(applicant.confirm_details).to be_nil }
      it { expect(applicant.confirm_dwp_result).to be_nil }
      it { expect(applicant.has_benefit_evidence).to be_nil }
    end

    context 'when the benefit check result is false' do
      before do
        applicant.benefit_check_result = false
      end

      it { expect(applicant.confirm_details).to eq 'yes' }
      it { expect(applicant.confirm_dwp_result).to eq 'no' }
      it { expect(applicant.has_benefit_evidence).to eq 'yes' }
    end

    context 'when the benefit check result is nil' do
      before do
        applicant.benefit_check_result = nil
      end

      it { expect(applicant.confirm_details).to eq 'yes' }
      it { expect(applicant.confirm_dwp_result).to eq 'no' }
      it { expect(applicant.has_benefit_evidence).to eq 'yes' }
    end
  end
end
