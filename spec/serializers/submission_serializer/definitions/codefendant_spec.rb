require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Codefendant do
  subject { described_class }

  let(:codefendant) do
    instance_double(
      Codefendant,
      first_name: 'Max',
      last_name: 'Mustermann',
      conflict_of_interest: 'Conflict of interest',
    )
  end

  let(:json_output) do
    {
      first_name: 'Max',
      last_name: 'Mustermann',
      conflict_of_interest: 'Conflict of interest',
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate(codefendant)).to eq(json_output) }
  end
end
