require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe SubmissionSerializer::Sections::IncomeDetails do
  subject { described_class.new(crime_application) }

  before do
    allow(subject).to receive(:requires_full_means_assessment?).and_return(false)
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      income: income,
      partner_detail: partner_detail,
      partner: partner,
      employments: [applicant_employment, partner_employment]
    )
  end

  let(:partner) { instance_double(Partner) }
  let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case:) }
  let(:involvement_in_case) { 'none' }
  let(:deductions_double) { double('deductions_collection', complete: deductions) }

  let(:income) do
    instance_double(
      Income,
      employments: [applicant_employment, partner_employment],
      employment_status: ['not_working'],
      ended_employment_within_three_months: 'yes',
      lost_job_in_custody: 'yes',
      date_job_lost: '2023-10-01',
      income_above_threshold: 'no',
      has_frozen_income_or_assets: 'no',
      client_owns_property: 'no',
      client_has_dependants: 'no',
      has_savings: 'yes',
      has_no_income_payments: nil,
      has_no_income_benefits: nil,
      partner_has_no_income_payments: nil,
      partner_has_no_income_benefits: nil,
      dependants: dependants,
      income_payments: [income_payment, partner_income_payment],
      income_benefits: [income_benefit, partner_income_benefit],
      manage_without_income: 'other',
      manage_other_details: 'Another way that they manage',
      partner_employment_status:  ['not_working'],
      applicant_other_work_benefit_received: nil,
      partner_other_work_benefit_received: nil,
      applicant_self_assessment_tax_bill: 'yes',
      applicant_self_assessment_tax_bill_amount_before_type_cast: 100_00,
      applicant_self_assessment_tax_bill_frequency: 'week',
      partner_self_assessment_tax_bill: 'no',
      partner_self_assessment_tax_bill_amount_before_type_cast: nil,
      partner_self_assessment_tax_bill_frequency: nil,
      known_to_be_full_means?: true,
    )
  end

  let(:dependants) { double(with_ages: [instance_double(Dependant, age: 10)]) }

  let(:income_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'other',
      amount_before_type_cast: 1802,
      frequency: 'annual',
      ownership_type: 'applicant',
      metadata: { 'details' => 'Side hustle' }
    )
  end

  let(:partner_income_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'maintenance',
      amount_before_type_cast: 602,
      frequency: 'week',
      ownership_type: 'partner',
      metadata: {}
    )
  end

  let(:income_benefit) do
    instance_double(
      IncomeBenefit,
      payment_type: 'child',
      amount_before_type_cast: 123,
      frequency: 'month',
      ownership_type: 'applicant',
      metadata: {},
    )
  end

  let(:partner_income_benefit) do
    instance_double(
      IncomeBenefit,
      payment_type: 'other',
      amount_before_type_cast: 909,
      frequency: 'month',
      ownership_type: 'partner',
      metadata: { 'details' => 'Grant money' },
    )
  end

  let(:deductions) do
    [
      instance_double(
        Deduction, deduction_type: 'income_tax',
                      amount_before_type_cast: 1000,
                      frequency: 'week',
                      details: nil,
                      annualized_amount: Money.new(100)
      ),
      instance_double(
        Deduction, deduction_type: 'national_insurance',
                      amount_before_type_cast: 2000,
                      frequency: 'fortnight',
                      details: nil,
                      annualized_amount: Money.new(200)
      ),
      instance_double(
        Deduction, deduction_type: 'other',
                      amount_before_type_cast: 3000,
                      frequency: 'annual',
                      details: 'deduction details',
                      annualized_amount: Money.new(300)
      )
    ]
  end

  let(:applicant_employment) do
    instance_double(Employment,
                    employer_name: 'Joe Goodwin',
                    job_title: 'Supervisor',
                    has_no_deductions: nil,
                    address: { address_line_one: 'address_line_one_y',
                                 address_line_two: 'address_line_two_y',
                                 city: 'city_y',
                                 country: 'country_y',
                                 postcode: 'postcode_y' }.as_json,
                    amount_before_type_cast: 25_000,
                    frequency: 'annual',
                    ownership_type: 'applicant',
                    metadata: { before_or_after_tax: { 'value' => 'before_tax' } }.as_json,
                    deductions: deductions_double,
                    complete?: true,
                    annualized_amount: Money.new(1500))
  end

  let(:partner_employment) do
    instance_double(Employment,
                    employer_name: 'Andy Goodwin',
                    job_title: 'Manager',
                    has_no_deductions: nil,
                    address: { address_line_one: 'address_line_one_z',
                               address_line_two: 'address_line_two_z',
                               city: 'city_z',
                               country: 'country_z',
                               postcode: 'postcode_z' }.as_json,
                    amount_before_type_cast: 35_000,
                    frequency: 'annual',
                    ownership_type: 'partner',
                    metadata: { before_or_after_tax: { 'value' => 'after_tax' } }.as_json,
                    deductions: deductions_double,
                    complete?: true,
                    annualized_amount: Money.new(2500))
  end

  describe '#generate' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:json_output) do
      {
        employment_type: ['not_working'],
        ended_employment_within_three_months: 'yes',
        lost_job_in_custody: 'yes',
        date_job_lost: '2023-10-01',
        income_above_threshold: 'no',
        has_frozen_income_or_assets: 'no',
        client_owns_property: 'no',
        client_has_dependants: 'no',
        has_savings: 'yes',
        manage_without_income: 'other',
        manage_other_details: 'Another way that they manage',
        dependants: [{ age: 10 }],
        partner_employment_type: ['not_working'],
        has_no_income_payments: nil,
        has_no_income_benefits: nil,
        partner_has_no_income_payments: nil,
        partner_has_no_income_benefits: nil,
        applicant_self_assessment_tax_bill: 'yes',
        applicant_self_assessment_tax_bill_amount: 100_00,
        applicant_self_assessment_tax_bill_frequency: 'week',
        partner_self_assessment_tax_bill: 'no',
        partner_self_assessment_tax_bill_amount: nil,
        partner_self_assessment_tax_bill_frequency: nil,
        applicant_other_work_benefit_received: nil,
        partner_other_work_benefit_received: nil,
        income_payments: [
          {
            payment_type: 'other',
            amount: 1802,
            frequency: 'annual',
            ownership_type: 'applicant',
            metadata: { 'details' => 'Side hustle' }
          },
          {
            payment_type: 'maintenance',
            amount: 602,
            frequency: 'week',
            ownership_type: 'partner',
            metadata: {},
          },
        ],
        income_benefits: [
          {
            payment_type: 'child',
            amount: 123,
            frequency: 'month',
            ownership_type: 'applicant',
            metadata: {},
          },
          {
            payment_type: 'other',
            amount: 909,
            frequency: 'month',
            ownership_type: 'partner',
            metadata: { 'details' => 'Grant money' },
          },
        ],
        employments: [
          {
            employer_name: 'Joe Goodwin',
            job_title: 'Supervisor',
            has_no_deductions: nil,
            address: {
              address_line_one: 'address_line_one_y',
              address_line_two: 'address_line_two_y',
              city: 'city_y',
              country: 'country_y',
              postcode: 'postcode_y'
            },
            amount: 25_000,
            frequency: 'annual',
            ownership_type: 'applicant',
            metadata: { before_or_after_tax: { 'value' => 'before_tax' } },
            deductions: [
              {
                deduction_type: 'income_tax',
                amount: 1000,
                frequency: 'week',
                details: nil
              },
              {
                deduction_type: 'national_insurance',
                amount: 2000,
                frequency: 'fortnight',
                details: nil
              },
              {
                deduction_type: 'other',
                amount: 3000,
                frequency: 'annual',
                details: 'deduction details'
              }
            ]
          },
          {
            employer_name: 'Andy Goodwin',
            job_title: 'Manager',
            has_no_deductions: nil,
            address: {
              address_line_one: 'address_line_one_z',
              address_line_two: 'address_line_two_z',
              city: 'city_z',
              country: 'country_z',
              postcode: 'postcode_z'
            },
            amount: 35_000,
            frequency: 'annual',
            ownership_type: 'partner',
            metadata: { before_or_after_tax: { 'value' => 'after_tax' } },
            deductions: [
              {
                deduction_type: 'income_tax',
                amount: 1000,
                frequency: 'week',
                details: nil
              },
              {
                deduction_type: 'national_insurance',
                amount: 2000,
                frequency: 'fortnight',
                details: nil
              },
              {
                deduction_type: 'other',
                amount: 3000,
                frequency: 'annual',
                details: 'deduction details'
              }
            ]
          }
        ],
        employment_income_payments: [
          {
            amount: 1500,
            frequency: 'annual',
            income_tax: 100,
            national_insurance: 200,
            ownership_type: 'applicant'
          },
          {
            amount: 2500,
            frequency: 'annual',
            income_tax: 100,
            national_insurance: 200,
            ownership_type: 'partner'
          }
        ],
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
