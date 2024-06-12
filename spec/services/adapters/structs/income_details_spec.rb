require 'rails_helper'

RSpec.describe Adapters::Structs::IncomeDetails do
  subject { application_struct.income }

  let(:application_struct) { build_struct_application(with_full_means: true) }

  describe '#employments' do
    it 'returns a employments collection' do
      # TODO: Need to update schema fixtures to improve the coverage
      # expect(subject.employments).to all(be_an(Employment))
    end
  end

  describe '#serializable_hash' do
    # rubocop:disable RSpec/ExampleLength
    it 'returns a serializable hash, including relationships' do
      expect(subject.serializable_hash).to match(
        a_hash_including(
          'employment_status' => ['employed'],
          'ended_employment_within_three_months' => 'yes',
          'lost_job_in_custody' => 'yes',
          'date_job_lost' => Date.new(2023, 9, 1),
          'income_above_threshold' => 'no',
          'has_frozen_income_or_assets' => 'no',
          'client_owns_property' => 'no',
          'has_savings' => 'yes',
          'manage_without_income' => 'other',
          'manage_other_details' => 'Another way they manage',
          'client_has_dependants' => 'yes',
          'has_no_income_benefits' => 'no',
          'has_no_income_payments' => 'no',
          'applicant_other_work_benefit_received' => 'no',
          'applicant_self_assessment_tax_bill' => 'yes',
          'applicant_self_assessment_tax_bill_amount' => 555_00,
          'applicant_self_assessment_tax_bill_frequency' => 'fortnight'
        )
      )
    end

    it 'contains all required attributes' do
      expect(subject.serializable_hash.keys).to match_array(
        %w[
          employment_status
          employment_details
          ended_employment_within_three_months
          lost_job_in_custody
          date_job_lost
          income_above_threshold
          has_frozen_income_or_assets
          client_owns_property
          has_savings
          manage_without_income
          manage_other_details
          client_has_dependants
          has_no_income_benefits
          has_no_income_payments
          partner_employment_status
          applicant_other_work_benefit_received
          applicant_self_assessment_tax_bill
          applicant_self_assessment_tax_bill_amount
          applicant_self_assessment_tax_bill_frequency
        ]
      )
    end
    # rubocop:enable RSpec/ExampleLength

    it 'omits income array' do
      expect(subject.serializable_hash.key?('income_payments')).to be false
    end
  end
end
