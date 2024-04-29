require 'rails_helper'

RSpec.describe Steps::Evidence::UploadForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }.merge(attributes)
  end

  let(:attributes) { {} }

  let(:applicant) { instance_double(Applicant, has_nino: 'yes') }
  let(:case) { instance_double(Case, case_type: CaseType::EITHER_WAY) }

  let(:crime_application) do
    instance_double(CrimeApplication, applicant:, case:)
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
      prompt_text = subject.result_for(group: :none, persona: :other).last.dig(:run, :other, :prompt).first

      expect(prompt_text).to eq 'their National Insurance number'
    end
  end
end
