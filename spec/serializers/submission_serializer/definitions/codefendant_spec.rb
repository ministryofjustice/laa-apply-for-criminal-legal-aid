require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Codefendant do
  subject { described_class.generate(codefendants) }

  let(:codefendants) { [codefendant1, codefendant2] }

  let(:codefendant1) do
    instance_double(
      Codefendant,
      first_name: 'Max',
      last_name: 'Mustermann',
      conflict_of_interest: 'yes',
    )
  end

  let(:codefendant2) do
    instance_double(
      Codefendant,
      first_name: 'Jane',
      last_name: 'Doe',
      conflict_of_interest: 'no',
    )
  end

  let(:json_output) do
    [
      {
        first_name: 'Max',
        last_name: 'Mustermann',
        conflict_of_interest: 'yes',
      },
      {
        first_name: 'Jane',
        last_name: 'Doe',
        conflict_of_interest: 'no',
      },
    ].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
