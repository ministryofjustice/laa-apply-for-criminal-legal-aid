require 'rails_helper'

RSpec.describe Business, type: :model do
  subject(:business) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe '#turnover' do
    subject(:turnover) { business.turnover }

    it 'is has a default amount of nil' do
      expect(turnover.amount).to be_nil
      expect(turnover.frequency).to be_nil
    end

    it 'sets the amount as a money object' do
      business.turnover.amount = '12.00'
    end
  end

  describe '#owner' do
    subject(:owner) { business.owner }

    let(:crime_application) do
      CrimeApplication.new(applicant: Applicant.new, partner: Partner.new)
    end

    let(:attributes) { { crime_application:, ownership_type: } }

    context 'when ownership type is not set' do
      let(:ownership_type) { nil }

      it { is_expected.to be_nil }
    end

    context 'when owned by applicant' do
      let(:ownership_type) { 'applicant' }

      it { is_expected.to be crime_application.applicant }
    end

    context 'when owned by partner' do
      let(:ownership_type) { 'partner' }

      it { is_expected.to be crime_application.partner }
    end
  end
end
