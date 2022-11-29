require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ApplicationDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 1,
      reference: '60000001',
      created_at: created_at,
      submitted_at: submitted_at,
      date_stamp: date_stamp,
      status: 'submitted',
    )
  end

  let(:created_at) { DateTime.new(2022, 12, 12) }
  let(:submitted_at) { DateTime.new(2022, 12, 15) }
  let(:date_stamp) { DateTime.new(2022, 12, 13) }

  let(:json_output) do
    {
      id: 1,
      application_type: '',
      reference: '60000001',
      created_at: created_at,
      submitted_at: submitted_at,
      date_stamp: date_stamp,
      schema_version: 1.0,
      status: 'submitted'
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
