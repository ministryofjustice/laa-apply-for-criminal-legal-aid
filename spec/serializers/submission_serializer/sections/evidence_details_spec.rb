require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::EvidenceDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      evidence_last_run_at:,
      evidence_prompts:,
    )
  end

  describe '#generate' do
    context 'when evidence prompts available' do
      let(:evidence_last_run_at) { DateTime.parse('2024-10-01 13:23:55.000000000 +0000') }
      let(:evidence_prompts) do
        [
          {
            id: 'ExampleRule1',
            group: 'income',
            ruleset: 'Latest',
            key: 'example_rule1',
            run: {
              client: {
                result: false,
                prompt: [],
              },
              partner: {
                result: true,
                prompt: ['show statements'],
              },
              other: {
                result: false,
                prompt: [],
              },
            }
          }
        ]
      end

      let(:output) do
        {
          evidence_details: {
            last_run_at: DateTime.parse('2024-10-01 13:23:55.000000000 +0000'),
            evidence_prompts: evidence_prompts,
          }
        }
      end

      # TODO: Not sure why subject.generate is not converting the nested hash into stringified keys!?
      it 'generates json' do
        expect(subject.generate.as_json).to eq(output.as_json)
      end
    end

    context 'when evidence prompts unavailable' do
      let(:evidence_last_run_at) { nil }
      let(:evidence_prompts) { [] }

      let(:output) do
        {
          evidence_details: { evidence_prompts: [] }
        }
      end

      it 'generates json' do
        expect(subject.generate.as_json).to eq(output.as_json)
      end
    end
  end
end
