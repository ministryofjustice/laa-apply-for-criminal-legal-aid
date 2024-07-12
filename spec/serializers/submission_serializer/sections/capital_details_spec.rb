require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::CapitalDetails do
  subject(:serializer) { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      capital: capital,
      income: income,
      partner_detail: partner_detail,
      partner: partner,
      non_means_tested?: false
    )
  end

  let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case:) }
  let(:partner) { instance_double(Partner) }
  let(:involvement_in_case) { 'none' }

  let(:capital) do
    instance_double(
      Capital,
      has_premium_bonds: 'yes',
      premium_bonds_total_value_before_type_cast: 123,
      premium_bonds_holder_number: '123A',
      partner_has_premium_bonds: 'yes',
      partner_premium_bonds_total_value_before_type_cast: 456,
      partner_premium_bonds_holder_number: '654B',
      will_benefit_from_trust_fund: 'yes',
      trust_fund_amount_held_before_type_cast: 1000,
      trust_fund_yearly_dividend_before_type_cast: 2000,
      partner_will_benefit_from_trust_fund: 'yes',
      partner_trust_fund_amount_held_before_type_cast: 2000,
      partner_trust_fund_yearly_dividend_before_type_cast: 200,
      savings: [],
      investments: [],
      national_savings_certificates: [],
      properties: [],
      has_frozen_income_or_assets: nil,
      has_no_investments: nil,
      has_no_savings: nil,
      has_national_savings_certificates: nil,
      has_no_properties: nil,
      has_no_other_assets: 'yes',
    )
  end

  let(:income) { instance_double(Income, has_frozen_income_or_assets: nil) }

  before do
    allow(serializer).to receive(:requires_full_means_assessment?).and_return(true)
  end

  describe '#generate' do
    context 'when requires full capital' do
      before do
        allow(serializer).to receive(:requires_full_capital?).and_return(true)
      end

      let(:json_output) do
        {
          has_premium_bonds: 'yes',
          premium_bonds_total_value: 123,
          premium_bonds_holder_number: '123A',
          partner_has_premium_bonds: 'yes',
          partner_premium_bonds_total_value: 456,
          partner_premium_bonds_holder_number: '654B',
          will_benefit_from_trust_fund: 'yes',
          trust_fund_amount_held: 1000,
          trust_fund_yearly_dividend: 2000,
          partner_will_benefit_from_trust_fund: 'yes',
          partner_trust_fund_amount_held: 2000,
          partner_trust_fund_yearly_dividend: 200,
          savings: [],
          investments: [],
          national_savings_certificates: [],
          properties: [],
          has_no_investments: nil,
          has_no_savings: nil,
          has_national_savings_certificates: nil,
          has_no_properties: nil,
          has_no_other_assets: 'yes'
        }.as_json
      end

      it { expect(subject.generate).to eq(json_output) }
    end

    context 'when does not require full capital' do
      before do
        allow(serializer).to receive(:requires_full_capital?).and_return(false)
        allow(capital).to receive(:has_frozen_income_or_assets).and_return('yes')
      end

      let(:json_output) do
        {
          :will_benefit_from_trust_fund => 'yes',
          :trust_fund_amount_held => 1000,
          :trust_fund_yearly_dividend => 2000,
          :partner_will_benefit_from_trust_fund => 'yes',
          :partner_trust_fund_amount_held => 2000,
          :partner_trust_fund_yearly_dividend => 200,
          :has_frozen_income_or_assets => 'yes',
          'has_no_other_assets' => 'yes'
        }.as_json
      end

      it { expect(subject.generate).to eq(json_output) }

      context 'when frozen asset question answered in income' do
        before do
          allow(income).to receive(:has_frozen_income_or_assets).and_return('no')
        end

        let(:json_output) do
          {
            :will_benefit_from_trust_fund => 'yes',
            :trust_fund_amount_held => 1000,
            :trust_fund_yearly_dividend => 2000,
            :partner_will_benefit_from_trust_fund => 'yes',
            :partner_trust_fund_amount_held => 2000,
            :partner_trust_fund_yearly_dividend => 200,
            'has_no_other_assets' => 'yes'
          }.as_json
        end

        it { expect(subject.generate).to eq(json_output) }
      end
    end
  end
end
