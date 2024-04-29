require 'rails_helper'

RSpec.describe Steps::Evidence::UploadForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }
  end

  let(:applicant) { instance_double(Applicant, has_nino: 'yes') }
  let(:kase) { instance_double(Case, case_type: CaseType::EITHER_WAY) }

  let(:crime_application) do
    instance_double(CrimeApplication, applicant:, kase:)
  end

  describe '#prompt' do
    subject { form.prompt }

    before do
      allow(crime_application).to receive_messages(
        :evidence_prompts => [],
        :evidence_prompts= => nil,
        :evidence_last_run_at => [],
        :evidence_last_run_at= => nil,
        :save! => true,
      )

      allow(applicant).to receive_messages(
        under18?: false,
      )
    end

    it 'generates a set of sentences' do
      sentences = subject.result_for(group: :none, persona: :other).last.dig(:run, :other, :prompt)

      expect(sentences).to eq ['their National Insurance number']
    end
  end
end
