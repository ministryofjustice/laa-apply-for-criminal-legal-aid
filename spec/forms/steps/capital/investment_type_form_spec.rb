require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, investments:, capital:) }
  let(:capital) { instance_double(Capital) }
  let(:investments) { class_double(Investment, where: existing_investments) }
  let(:existing_investments) { [] }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq(InvestmentType::VALUES)
    end
  end

  describe '#investment_type' do
    subject(:investment_type) { form.investment_type }

    context 'when the question has not been answered' do
      before { allow(capital).to receive(:has_no_investments).and_return(nil) }

      it { is_expected.to be_nil }
    end

    context 'when capital#has_no_investments "yes"' do
      before { allow(capital).to receive(:has_no_investments).and_return('yes') }

      it { is_expected.to eq 'none' }
    end
  end

  describe '#validations' do
    before do
      allow(form).to receive(:include_partner_in_means_assessment?) { include_partner? }
      form.investment_type = nil
    end

    let(:include_partner?) { false }

    let(:error_message) do
      'Select which investments your client has inside or outside the UK, ' \
        "or select 'They do not have any of these investments'"
    end

    it { is_expected.to validate_presence_of(:investment_type, :blank, error_message) }

    context 'when partner is included in means assessment' do
      let(:include_partner?) { true }

      let(:error_message) do
        'Select which investments your client or their partner has inside or outside the UK, ' \
          "or select 'They do not have any of these investments'"
      end

      it { is_expected.to validate_presence_of(:investment_type, :blank, error_message) }
    end
  end

  describe '#save' do
    let(:investment_type) { InvestmentType.values.sample.to_s }
    let(:new_investment) { instance_double(Investment) }
    let(:existing_investment) { instance_double(Investment, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(investments).to receive(:create!).with(investment_type:).and_return new_investment
      allow(capital).to receive(:update).and_return true

      form.investment_type = investment_type
      form.save
    end

    context 'when client has no investments' do
      let(:investment_type) { 'none' }

      it 'does not set or create a investment' do
        expect(form.investment).to be_nil
        expect(investments).not_to have_received(:create!)
      end

      it 'updates the capital#has_no_savings to "yes"' do
        expect(capital).to have_received(:update).with(has_no_investments: 'yes')
      end
    end

    context 'when there are no existing investment records of the selected investment type' do
      it 'a new investment record of the investment type is created' do
        expect(form.investment).to be new_investment
        expect(investments).to have_received(:create!).with(investment_type:)
      end

      it 'sets capital#has_no_savings to nil' do
        expect(capital).to have_received(:update).with(has_no_investments: nil)
      end
    end

    context 'when an investment record of the selected investment type exists' do
      let(:existing_investments) { [existing_investment] }

      it 'is set as the investment record' do
        expect(form.investment).to be existing_investment
        expect(investments).not_to have_received(:create!)
      end

      context 'when the existing investment record is complete' do
        let(:complete?) { true }

        it 'a new investment record of the selected investment type is created' do
          expect(form.investment).to be new_investment
          expect(investments).to have_received(:create!).with(investment_type:)
        end
      end
    end
  end
end
