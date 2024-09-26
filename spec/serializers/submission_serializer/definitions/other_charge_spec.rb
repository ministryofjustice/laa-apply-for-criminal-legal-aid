require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::OtherCharge do
  subject { described_class.generate(other_charge) }

  let(:other_charge) do
    instance_double(
      OtherCharge,
      charge: 'Theft',
      hearing_court_name: "Cardiff Magistrates' Court",
      next_hearing_date: '2025-01-15',
    )
  end

  let(:json_output) do
    {
      charge: 'Theft',
      hearing_court_name: "Cardiff Magistrates' Court",
      next_hearing_date: '2025-01-15',
    }.as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
