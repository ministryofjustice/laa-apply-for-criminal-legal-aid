require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::IncomeDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double CrimeApplication, income: income, employments: [employment] }
  let(:deductions_double) { double('deductions_collection', complete: deductions) }

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
      client_has_dependants: 'no',
      has_savings: 'yes',
      has_no_income_payments: nil,
      has_no_income_benefits: nil,
      dependants: dependants,
      income_payments: [income_payment],
      income_benefits: [income_benefit],
      manage_without_income: 'other',
      manage_other_details: 'Another way that they manage',
    )
  end

  let(:dependants) { double(with_ages: [instance_double(Dependant, age: 10)]) }

  let(:income_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'other',
      amount_before_type_cast: 1802,
      frequency: 'annual',
      metadata: { 'details' => 'Side hustle' }
    )
  end

  let(:income_benefit) do
    instance_double(
      IncomeBenefit,
      payment_type: 'child',
      amount_before_type_cast: 123,
      frequency: 'month',
      metadata: { 'details' => 'Extra topup' },
    )
  end

  let(:deductions) do
    [
      instance_double(
        Deduction, deduction_type: 'income_tax',
                      amount_before_type_cast: 1000,
                      frequency: 'week',
                      details: nil
      ),
      instance_double(
        Deduction, deduction_type: 'national_insurance',
                      amount_before_type_cast: 2000,
                      frequency: 'fortnight',
                      details: nil
      ),
      instance_double(
        Deduction, deduction_type: 'other',
                      amount_before_type_cast: 3000,
                      frequency: 'annual',
                      details: 'deduction details'
      )
    ]
  end

  let(:employment) do
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
                    metadata: { before_or_after_tax: {'value' => 'before_tax'} }.as_json,
                    deductions: deductions_double)
  end

  describe '#generate' do
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
        has_no_income_payments: nil,
        has_no_income_benefits: nil,
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
            metadata: { before_or_after_tax: {'value' => 'before_tax'} },
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
        ]
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end
end
