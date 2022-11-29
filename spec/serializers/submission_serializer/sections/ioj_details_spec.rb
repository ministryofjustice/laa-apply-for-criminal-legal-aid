require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::IojDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.new }
  let(:ioj) do
    Ioj.new(
      types: %w[reputation other],
      reputation_justification: 'A justification',
      other_justification: 'Another justification',
    )
  end

  let(:json_output) do
    {
      interests_of_justice: [
        {
          type: 'reputation',
          reason: 'A justification'
        },
        {
          type: 'other',
          reason: 'Another justification'
        }
      ]
    }.as_json
  end

  before do
    allow(crime_application).to receive(:ioj).and_return(ioj)
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
