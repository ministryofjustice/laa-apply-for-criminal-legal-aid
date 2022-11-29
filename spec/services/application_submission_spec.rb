require 'rails_helper'

RSpec.describe ApplicationSubmission do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      date_stamp:,
    )
  end

  let(:submission_serializer) { instance_double(SubmissionSerializer::Application, generate: payload) }
  let(:payload) { { 'foo' => 'bar' } }

  before do
    allow(crime_application).to receive(:update!).and_return(true)

    allow(
      SubmissionSerializer::Application
    ).to receive(:new).with(crime_application).and_return(submission_serializer)

    stub_request(:post, 'http://datastore-webmock/api/v1/applications')
      .with(body: { application: payload })
      .to_return(status: 201, body: '{}')
  end

  describe '#call' do
    let(:submitted_date) { DateTime.new(2022, 12, 31) }
    let(:date_stamp) { nil }

    before do
      travel_to submitted_date
    end

    context 'when `date_stamp` attribute is `nil`' do
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

    context 'submission to the datastore' do
      it 'calls the API and submits the serialized application' do
        expect(subject.call).to be(true)

        expect(
          a_request(
            :post, 'http://datastore-webmock/api/v1/applications'
          ).with(body: { application: payload })
        ).to have_been_made.once
      end
    end
  end
end
