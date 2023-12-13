require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Dependant do
  subject { described_class.generate(dependants) }

  let(:dependants) { [dependant1, dependant2] }

  let(:dependant1) do
    instance_double(
      Dependant,
      age: 17,
    )
  end

  let(:dependant2) do
    instance_double(
      Dependant,
      age: 0,
    )
  end

  let(:json_output) do
    [{ age: 17 }, { age: 0 }].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
