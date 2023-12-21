require 'rails_helper'

RSpec.describe Adapters::Structs::Dependant do
  subject { application_struct.dependants.second }

  let(:json) do
    data = JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application').read)
    data.deep_merge!('means_details' => { 'dependants' => [{ age: 0 }, { age: 17 }] })
  end

  let(:application_struct) { build_struct_application(json:) }

  describe '#serializable_hash' do
    it 'returns a serializable hash' do
      expect(
        subject.serializable_hash
      ).to a_hash_including(
        'age' => 17
      )
    end

    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          age
        ]
      )
    end
  end
end
