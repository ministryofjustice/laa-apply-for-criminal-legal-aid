require 'rails_helper'
require 'laa_crime_schemas'

RSpec.describe ApplicationSubmission do
  subject { described_class.new(crime_application) }

  let(:applicant) do
    instance_double(
      Applicant,
      first_name: 'Max',
      last_name: 'Mustermann',
      date_of_birth: Date.new(1990, 2, 1),
      nino: 'AJ123456C',
      home_address: nil,
    )
  end

  let(:submitted_at) { nil }

  let(:status) { nil }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: '1',
      created_at: DateTime.new(2022, 11, 20),
      submitted_at: submitted_at,
      status: status,
      date_stamp: date_stamp,
      applicant: applicant,
      reference: 6_000_001,
    )
  end

  before do
    allow(crime_application).to receive(:update!).and_return(true)

    stub_request(:post, 'http://datastore-webmock/api/v1/applications')
      .to_return(status: 201, body: '{}')
  end

  describe '#call' do
    let(:submitted_date) { DateTime.new(2022, 12, 31) }

    before do
      travel_to submitted_date
    end

    context 'when `date_stamp` attribute is `nil`' do
      let(:date_stamp) { nil }

      it 'marks the application as submitted, setting the `date_stamp` to the submission date' do
        expect(
          crime_application
        ).to receive(:update!).with(
          status: :submitted, submitted_at: submitted_date, date_stamp: submitted_date
        )

        expect(subject.call).to be(true)
      end
    end

    context 'when there is already a `date_stamp`' do
      let(:date_stamp) { DateTime.new(2022, 12, 15) }

      it 'marks the application as submitted, do not change the `date_stamp`' do
        expect(
          crime_application
        ).to receive(:update!).with(
          status: :submitted, submitted_at: submitted_date, date_stamp: date_stamp
        )

        expect(subject.call).to be(true)
      end
    end
  end
end
