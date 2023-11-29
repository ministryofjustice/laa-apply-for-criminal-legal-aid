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
          'income_above_threshold' => 'yes',
          'lost_job_in_custody' => 'yes',
          'date_job_lost' => Date.new(2023, 9, 1),
        )
      )
    end

    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          income_above_threshold
          lost_job_in_custody
          date_job_lost
        ]
      )
    end
  end
end
