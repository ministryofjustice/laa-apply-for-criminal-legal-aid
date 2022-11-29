require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Person do
  subject { described_class }

  let(:person) do
    instance_double(
      Person,
      first_name: 'Max',
      last_name: 'Mustermann',
      date_of_birth: date_of_birth,
      home_address: nil
    )
  end

  let(:date_of_birth) { DateTime.new(2000, 1, 1) }

  let(:json_output) do
    {
      first_name: 'Max',
      last_name: 'Mustermann',
      date_of_birth: date_of_birth,
      home_address: nil,
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate(person)).to eq(json_output) }
  end
end
