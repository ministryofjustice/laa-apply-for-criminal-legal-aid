require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::SlipstreamAuditSelectionOutcome do
  subject(:serialized_outcome) { described_class.generate(outcome) }

  let(:outcome) do
    instance_double(
      SlipstreamAuditSelectionOutcome,
      status: 'confirmed',
      sample_rate: 10,
      sampled_at: DateTime.new(2026, 9, 3, 10),
      status_determined_at: DateTime.new(2026, 9, 4, 11),
      selection_reason: nil
    )
  end

  it 'serializes the outcome and its sampling metadata' do
    expect(serialized_outcome).to eq(
      {
        status: 'confirmed',
        sample_rate: 10,
        sampled_at: DateTime.new(2026, 9, 3, 10),
        status_determined_at: DateTime.new(2026, 9, 4, 11)
      }.as_json
    )
  end

  it 'serializes every supported status without changing it' do
    SlipstreamAuditSelectionOutcome.statuses.each_key do |status|
      allow(outcome).to receive(:status).and_return(status)

      expect(described_class.generate(outcome)).to include('status' => status)
    end
  end

  it 'includes selection_reason when present' do
    allow(outcome).to receive(:selection_reason).and_return('offence')

    expect(serialized_outcome).to include('selection_reason' => 'offence')
  end

  it 'omits selection_reason when absent' do
    expect(serialized_outcome).not_to have_key('selection_reason')
  end
end
