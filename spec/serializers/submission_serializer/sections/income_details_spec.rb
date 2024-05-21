require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::IncomeDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double CrimeApplication, income: }

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
          ]
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end
end
