require 'rails_helper'

RSpec.describe Steps::Capital::OtherInvestmentTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, investments:, partner_detail:) }
  let(:investments) { double }
  let(:investment_type) { InvestmentType.values.sample.to_s }
  let(:new_investment) { instance_double(Investment) }
  let(:partner_detail) { nil }

  describe '#choices' do
    it 'returns investment types' do
      expect(form.choices).to match InvestmentType.values
    end
  end

  describe '#save' do
    before do
      allow(investments).to receive(:create!).with(investment_type:).and_return new_investment

      form.investment_type = investment_type
      form.save
    end

    context 'when a investment of the type exists' do
      it 'a new investment of the investment type is created' do
        expect(form.investment).to be new_investment
        expect(investments).to have_received(:create!).with(investment_type:)
      end
    end

    context 'when investment type is an empty string' do
      let(:investment_type) { '' }

      it 'does not create an investment' do
        expect(investments).not_to have_received(:create!).with(investment_type:)
      end
    end
  end
end
