require 'rails_helper'

RSpec.describe Adapters::Structs::InterestsOfJustice do
  subject { described_class.new(ioj) }

  let(:application_struct) do
    Adapters::Structs::CrimeApplication.new(
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  let(:ioj) { application_struct.ioj }

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
  end
end
