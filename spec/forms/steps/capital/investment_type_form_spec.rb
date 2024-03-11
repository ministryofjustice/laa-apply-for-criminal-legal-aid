require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, investments:) }
  let(:investments) { class_double(Investment, where: existing_investments) }
  let(:existing_investments) { [] }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq(InvestmentType::VALUES)
    end
  end

  describe '#save' do
    let(:investment_type) { InvestmentType.values.sample }
    let(:new_investment) { instance_double(Investment) }
    let(:existing_investment) { instance_double(Investment, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(investments).to receive(:create!).with(investment_type:).and_return new_investment

      form.investment_type = investment_type
      form.save
    end

    context 'when client has no investments' do
      let(:investment_type) { 'none' }

      it 'returns true but does not set or create a investment' do
        expect(form.investment).to be_nil
        expect(investments).not_to have_received(:create!)
      end
    end

    context 'when there are no investments of the investment type' do
      it 'a new investment of the investment type is created' do
        expect(form.investment).to be new_investment
        expect(investments).to have_received(:create!).with(investment_type:)
      end
    end

    context 'when a investment of the type exists' do
      let(:existing_investments) { [existing_investment] }

      it 'is set as the investment' do
        expect(form.investment).to be existing_investment
        expect(investments).not_to have_received(:create!)
      end

      context 'when the existing investment is complete' do
        let(:complete?) { true }

        it 'a new investment of the investment type is created' do
          expect(form.investment).to be new_investment
          expect(investments).to have_received(:create!).with(investment_type:)
        end
      end
    end
  end
end
