require 'rails_helper'

RSpec.describe Adapters::Structs::IncomeDetails do
  subject { application_struct.income }

  let(:application_struct) { build_struct_application }

  describe '#serializable_hash' do
    it 'returns a serializable hash, including relationships' do
      expect(
        subject.serializable_hash
      ).to match(
        a_hash_including(
          'employment_status' => ['not_working'],
          'ended_employment_within_three_months' => 'yes',
          'lost_job_in_custody' => 'yes',
          'date_job_lost' => Date.new(2023, 9, 1),
          'income_above_threshold' => 'no',
          'has_frozen_income_or_assets' => 'no',
          'client_owns_property' => 'no',
          'has_savings' => 'no',
          'manage_without_income' => 'other',
          'manage_other_details' => 'Another way they manage',
          'client_has_dependants' => nil,
        )
      )
    end

    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          employment_status
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
        ]
      )
    end
  end
end
