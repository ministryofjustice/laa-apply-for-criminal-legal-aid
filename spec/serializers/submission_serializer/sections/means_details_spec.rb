require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::MeansDetails do
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      income:,
      outgoings:,
      outgoings_payments:,
      dependants:,
      income_payments:,
      income_benefits:,
      capital:,
      savings:,
      investments:,
      national_savings_certificates:,
      properties:
    )
  end

  let(:dependants) do
    double(Array, with_ages: [])
  end

  let(:savings) { [] }
  let(:investments) { [] }
  let(:national_savings_certificates) { [] }
  let(:properties) { [] }

  describe '#generate' do
    let(:income) do
      instance_double(
        Income,
        employment_status: ['not_working'],
        ended_employment_within_three_months: 'yes',
        lost_job_in_custody: 'yes',
        date_job_lost: '2023-10-01',
        income_above_threshold: 'no',
        has_frozen_income_or_assets: 'no',
        client_owns_property: 'no',
        has_savings: 'yes',
        manage_without_income: 'other',
        manage_other_details: 'Another way that they manage',
      )
    end

    let(:outgoings) do
      instance_double(
        Outgoings,
        housing_payment_type: 'mortgage',
        income_tax_rate_above_threshold: 'no',
        outgoings_more_than_income: 'yes',
        pays_council_tax: 'yes',
        how_manage: 'A description of how they manage'
      )
    end

    let(:outgoings_payments) do
      [
        instance_double(
          OutgoingsPayment,
          payment_type: 'council_tax',
          amount_before_type_cast: 14_744,
          frequency: 'month',
          metadata: {},
        ),
        instance_double(
          OutgoingsPayment,
          payment_type: HousingPaymentType::MORTGAGE,
          amount_before_type_cast: 3_292_900,
          frequency: 'annual',
          metadata: {},
        )
      ]
    end

    let(:income_payments) do
      [
        instance_double(
          IncomePayment,
          payment_type: 'other',
          amount_before_type_cast: 1802,
          frequency: 'annual',
          metadata: { 'details' => 'Side hustle' }
        )
      ]
    end

    let(:income_benefits) do
      [
        instance_double(
          IncomeBenefit,
          payment_type: 'child',
          amount_before_type_cast: 123,
          frequency: 'month',
          metadata: { 'details' => 'Extra topup' },
        )
      ]
    end

    let(:capital) do
      instance_double(
        Capital,
        has_premium_bonds: 'yes',
        premium_bonds_total_value_before_type_cast: 123,
        premium_bonds_holder_number: '123A',
        will_benefit_from_trust_fund: 'yes',
        trust_fund_amount_held_before_type_cast: 1000,
        trust_fund_yearly_dividend_before_type_cast: 2000,
        savings: [],
        investments: [],
        national_savings_certificates: [],
        properties: [],
        has_frozen_income_or_assets: nil,
        has_no_other_assets: 'yes'
      )
    end

    let(:json_output) do
      {
        means_details: {
          income_details: {
            employment_type: ['not_working'],
            ended_employment_within_three_months: 'yes',
            lost_job_in_custody: 'yes',
            date_job_lost: '2023-10-01',
            income_above_threshold: 'no',
            has_frozen_income_or_assets: 'no',
            client_owns_property: 'no',
            has_savings: 'yes',
            manage_without_income: 'other',
            manage_other_details: 'Another way that they manage',
            dependants: [],
            income_payments: [{
              payment_type: 'other',
              amount: 1802,
              frequency: 'annual',
              metadata: { 'details' => 'Side hustle' }
            }],
            income_benefits: [
              payment_type: 'child',
              amount: 123,
              frequency: 'month',
              metadata: { 'details' => 'Extra topup' },
            ],
          },
          outgoings_details: {
            outgoings: [
              {
                payment_type: 'council_tax',
                amount: 14_744,
                frequency: 'month',
                metadata: {},
              },
              {
                payment_type: 'mortgage',
                amount: 3_292_900,
                frequency: 'annual',
                metadata: {},
              }
            ],
            housing_payment_type: 'mortgage',
            income_tax_rate_above_threshold: 'no',
            outgoings_more_than_income: 'yes',
            how_manage: 'A description of how they manage',
            pays_council_tax: 'yes',
          },
          capital_details: {
            has_premium_bonds: 'yes',
            premium_bonds_total_value: 123,
            premium_bonds_holder_number: '123A',
            will_benefit_from_trust_fund: 'yes',
            trust_fund_amount_held: 1000,
            trust_fund_yearly_dividend: 2000,
            savings: [],
            investments: [],
            national_savings_certificates: [],
            properties: [],
            has_frozen_income_or_assets: nil,
            has_no_other_assets: 'yes'
          }
        }
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end

  context 'when optional fields are not supplied' do
    let(:income) do
      instance_double(
        Income,
        employment_status: ['not_working'],
        ended_employment_within_three_months: nil,
        lost_job_in_custody: nil,
        date_job_lost: nil,
        income_above_threshold: 'no',
        has_frozen_income_or_assets: nil,
        client_owns_property: nil,
        has_savings: nil,
        manage_without_income: nil,
        manage_other_details: nil
      )
    end

    let(:outgoings) do
      instance_double(
        Outgoings,
        housing_payment_type: nil,
        income_tax_rate_above_threshold: nil,
        outgoings_more_than_income: nil,
        how_manage: nil,
        pays_council_tax: nil,
      )
    end

    let(:json_output) do
      {
        means_details: {
          income_details: {
            employment_type: ['not_working'],
            ended_employment_within_three_months: nil,
            lost_job_in_custody: nil,
            date_job_lost: nil,
            income_above_threshold: 'no',
            has_frozen_income_or_assets: nil,
            client_owns_property: nil,
            has_savings: nil,
            manage_without_income: nil,
            manage_other_details: nil,
            dependants: [],
            income_payments: nil,
            income_benefits: nil,
          },
          outgoings_details: {
            outgoings: nil,
            housing_payment_type: nil,
            income_tax_rate_above_threshold: nil,
            outgoings_more_than_income: nil,
            how_manage: nil,
            pays_council_tax: nil,
          }
        }
      }.as_json
    end

    let(:income_payments) do
      nil
    end

    let(:income_benefits) do
      nil
    end

    let(:outgoings_payments) do
      nil
    end

    let(:capital) do
      nil
    end

    it 'does not output lost_job_in_custody_fields' do
      expect(subject.generate).to eq(json_output)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
