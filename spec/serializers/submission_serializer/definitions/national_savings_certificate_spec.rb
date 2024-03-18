require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::NationalSavingsCertificate do
  subject { described_class.generate(national_savings_certificates) }

  let(:national_savings_certificates) do
    [
      NationalSavingsCertificate.new(
        holder_number: 'A1',
        certificate_number: 'B2',
        value: 10_001,
        ownership_type: OwnershipType::APPLICANT
      )
    ]
  end

  let(:json_output) do
    [
      {
        holder_number: 'A1',
        certificate_number: 'B2',
        value: 10_001,
        ownership_type: 'applicant'
      }
    ].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
