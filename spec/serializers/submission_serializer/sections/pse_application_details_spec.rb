require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::PseApplicationDetails do
  subject { described_class.new(crime_application) }

  let(:created_at) { DateTime.new(2022, 12, 12) }
  let(:submitted_at) { DateTime.new(2022, 12, 15) }

  describe '#generate' do
    context 'with a PSE application' do
      let(:crime_application) do
        instance_double(
          CrimeApplication,
          id: 'uuid',
          parent_id: 'uuid_of_parent_application',
          reference: 10_000_001,
          created_at: created_at,
          submitted_at: submitted_at,
          application_type: 'post_submission_evidence',
          ioj_passport: ['on_age_under18'],
          means_passport: ['on_age_under18'],
          additional_information: 'PSE additional information',
        )
      end

      let(:json_output) do
        {
          id: 'uuid',
          parent_id: 'uuid_of_parent_application',
          schema_version: 1.0,
          reference: 10_000_001,
          application_type: 'post_submission_evidence',
          created_at: created_at,
          submitted_at: submitted_at,
          additional_information: 'PSE additional information'
        }.as_json
      end

      it { expect(subject.generate).to eq(json_output) }
    end
  end
end
