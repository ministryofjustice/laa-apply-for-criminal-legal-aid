require 'rails_helper'

RSpec.describe Steps::Capital::PartnerTrustFundForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: capital,
    }.merge(attributes)
  end

  let(:attributes) { {} }

  let(:capital) { instance_double(Capital) }

  let(:crime_application) do
    instance_double(CrimeApplication, capital:)
  end

  describe 'validations' do
    it { is_expected.to validate_is_a(:partner_will_benefit_from_trust_fund, YesNoAnswer) }

    context 'when `partner_will_benefit_from_trust_fund` answered yes' do
      before { form.partner_will_benefit_from_trust_fund = 'yes' }

      it { is_expected.to validate_presence_of(:partner_trust_fund_amount_held) }
      it { is_expected.to validate_presence_of(:partner_trust_fund_yearly_dividend) }
    end

    context 'when `partner_will_benefit_from_trust_fund` answered no' do
      before { form.partner_will_benefit_from_trust_fund = 'no' }

      it { is_expected.not_to validate_presence_of(:partner_trust_fund_amount_held) }
      it { is_expected.not_to validate_presence_of(:partner_trust_fund_yearly_dividend) }
    end
  end

  describe '#save' do
    context 'for valid details' do
      before do
        allow(capital).to receive(:update).and_return(true)

        form.partner_will_benefit_from_trust_fund = partner_will_benefit_from_trust_fund
        form.partner_trust_fund_amount_held = '100023.00'
        form.partner_trust_fund_yearly_dividend = '2000.00'

        subject.save
      end

      context 'when `partner_will_benefit_from_trust_fund` answered yes' do
        let(:partner_will_benefit_from_trust_fund) { 'yes' }

        let(:expected_args) do
          {
            partner_will_benefit_from_trust_fund: YesNoAnswer::YES,
            partner_trust_fund_amount_held: Money.new(10_002_300),
            partner_trust_fund_yearly_dividend: Money.new(200_000)
          }
        end

        it 'updates capital with trust fund details' do
          expect(capital).to have_received(:update).with(expected_args.stringify_keys)
        end
      end

      context 'when `partner_will_benefit_from_trust_fund` answered no' do
        let(:partner_will_benefit_from_trust_fund) { 'no' }

        let(:expected_args) do
          {
            partner_will_benefit_from_trust_fund: YesNoAnswer::NO,
            partner_trust_fund_amount_held: nil,
            partner_trust_fund_yearly_dividend: nil
          }.stringify_keys
        end

        it 'updates the record and sets the detail attributes to nil' do
          expect(capital).to have_received(:update).with(expected_args)
        end
      end
    end
  end
end
