require 'rails_helper'

RSpec.describe Adapters::Structs::OutgoingsDetails do
  subject { application_struct.outgoings }

  let(:application_struct) { build_struct_application }

  describe '#serializable_hash' do
    it 'returns a serializable hash' do
      expect(
        subject.serializable_hash
      ).to match(
        a_hash_including(
          'outgoings_more_than_income' => 'yes',
          'how_manage' => 'A description of how they manage'
        )
      )
    end

    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          outgoings_more_than_income
          how_manage
        ]
      )
    end
  end
end
