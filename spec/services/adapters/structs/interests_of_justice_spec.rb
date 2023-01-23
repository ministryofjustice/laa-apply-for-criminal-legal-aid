require 'rails_helper'

RSpec.describe Adapters::Structs::InterestsOfJustice do
  subject { application_struct.ioj }

  let(:application_struct) do
    Adapters::Structs::CrimeApplication.new(
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe '#types' do
    it 'returns the IoJ types' do
      expect(subject.types).to eq(['loss_of_liberty'])
    end
  end

  describe 'justification for a given type' do
    it 'returns the `loss_of_liberty` justification' do
      expect(
        subject[:loss_of_liberty_justification]
      ).to eq('More details about loss of liberty.')
    end

    it 'returns nil if there is no justification for a type' do
      expect(
        subject[:witness_tracing_justification]
      ).to be_nil
    end
  end

  describe '#serializable_hash' do
    # rubocop:disable RSpec/ExampleLength
    it 'has the expected attributes from the fixture' do
      expect(
        subject.serializable_hash
      ).to eq(
        {
          'types' => ['loss_of_liberty'],
          'loss_of_liberty_justification' => 'More details about loss of liberty.',
          'suspended_sentence_justification' => nil,
          'loss_of_livelihood_justification' => nil,
          'reputation_justification' => nil,
          'question_of_law_justification' => nil,
          'understanding_justification' => nil,
          'witness_tracing_justification' => nil,
          'expert_examination_justification' => nil,
          'interest_of_another_justification' => nil,
          'other_justification' => nil,
        }
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
