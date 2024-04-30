require 'rails_helper'

RSpec.describe Steps::Evidence::UploadForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }
  end

  let(:crime_application) do
    CrimeApplication.new(
      applicant: Applicant.new(
        has_nino: 'yes',
        date_of_birth: '200-01-01'
      )
    )
  end

  describe '#prompt' do
    subject { form.prompt }

    it 'generates a set of sentences' do
      sentences = subject.result_for(group: :none, persona: :other).last.dig(:run, :other, :prompt)

      expect(sentences).to eq ['their National Insurance number']
    end
  end
end
