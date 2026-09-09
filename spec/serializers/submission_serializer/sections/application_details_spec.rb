require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ApplicationDetails do
  subject { described_class.new(crime_application) }

  before do
    allow(Passporting::MeansPassporter).to receive(:new).and_return(
      instance_double(
        Passporting::MeansPassporter,
        means_passport: ['on_age_under18']
      )
    )
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      parent_id: nil,
      application_type: 'initial',
      reference: 10_000_001,
      created_at: created_at,
      submitted_at: submitted_at,
      date_stamp: date_stamp,
      date_stamp_context: date_stamp_context,
      is_means_tested: 'yes',
      ioj_passport: ['on_age_under18'],
      applicant: double,
      additional_information: 'More details',
      pre_cifc_reference_number: 'pre_cifc_usn',
      pre_cifc_maat_id: nil,
      pre_cifc_usn: 'USN123',
      pre_cifc_reason: 'Won the lottery',
      slipstream_audit_selection_outcome: selection_outcome,
    )
  end

  let(:created_at) { DateTime.new(2022, 12, 12) }
  let(:submitted_at) { DateTime.new(2022, 12, 15) }
  let(:date_stamp) { DateTime.new(2022, 12, 13) }
  let(:date_of_birth) { Date.new(1990, 1, 1) }
  let(:selection_outcome) do
    instance_double(
      SlipstreamAuditSelectionOutcome,
      status: 'confirmed',
      sample_rate: 10,
      sampled_at: DateTime.new(2026, 9, 3, 10),
      status_determined_at: DateTime.new(2026, 9, 4, 11)
    )
  end

  let(:date_stamp_context) do
    DateStampContext.new(
      first_name: 'Fred',
      last_name: 'Flintstone',
      date_of_birth: date_of_birth,
      date_stamp: date_stamp,
      created_at: date_stamp,
    )
  end

  let(:json_output) do
    {
      id: 'uuid',
      parent_id: nil,
      schema_version: 1.0,
      reference: 10_000_001,
      application_type: 'initial',
      created_at: created_at,
      submitted_at: submitted_at,
      date_stamp: date_stamp,
      date_stamp_context: {
        first_name: 'Fred',
        last_name: 'Flintstone',
        date_of_birth: date_of_birth,
        date_stamp: date_stamp,
        created_at: date_stamp,
      },
      is_means_tested: 'yes',
      ioj_passport: ['on_age_under18'],
      means_passport: ['on_age_under18'],
      additional_information: 'More details',
      pre_cifc_reference_number: 'pre_cifc_usn',
      pre_cifc_maat_id: nil,
      pre_cifc_usn: 'USN123',
      pre_cifc_reason: 'Won the lottery',
      slipstream_audit_selection_outcome: {
        status: 'confirmed',
        sample_rate: 10,
        sampled_at: DateTime.new(2026, 9, 3, 10),
        status_determined_at: DateTime.new(2026, 9, 4, 11)
      },
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }

    context 'without a slipstream audit selection outcome' do
      let(:selection_outcome) { nil }

      it 'omits the outcome' do
        expect(subject.generate).not_to have_key('slipstream_audit_selection_outcome')
      end
    end
  end
end
