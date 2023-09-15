require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ApplicationDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      parent_id: nil,
      reference: 10_000_001,
      created_at: created_at,
      submitted_at: submitted_at,
      date_stamp: date_stamp,
      ioj_passport: ['on_age_under18'],
      means_passport: ['on_age_under18'],
    )
  end

  let(:created_at) { DateTime.new(2022, 12, 12) }
  let(:submitted_at) { DateTime.new(2022, 12, 15) }
  let(:date_stamp) { DateTime.new(2022, 12, 13) }

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
      ioj_passport: ['on_age_under18'],
      means_passport: ['on_age_under18'],
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
