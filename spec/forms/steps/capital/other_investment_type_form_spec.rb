require 'rails_helper'

RSpec.describe Steps::Capital::OtherInvestmentTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, investments:) }
  let(:investments) { class_double(Investment, where: existing_investments) }
  let(:existing_investments) { [instance_double(Investment, complete?: false)] }
  let(:investment_type) { InvestmentType.values.sample }
  let(:new_investment) { instance_double(Investment) }

  describe '#save' do
    before do
      allow(investments).to receive(:create).with(investment_type:).and_return new_investment

      form.investment_type = investment_type
      form.save
    end

    context 'when a investment of the type exists' do
      it 'a new investment of the investment type is created' do
        expect(form.investment).to be new_investment
        expect(investments).to have_received(:create).with(investment_type:)
      end
    end
  end
end
