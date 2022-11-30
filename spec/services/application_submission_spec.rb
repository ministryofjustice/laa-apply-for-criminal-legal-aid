require 'rails_helper'

RSpec.describe ApplicationSubmission do
  #
  # NOTE: we are using real DB records here as a way of testing
  # an end to end full serialized application posted to the datastore.
  #
  subject { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.find_by(usn: 123) }
  let(:payload) { subject.application_payload }

  before :all do
    # create all neccessary records
    app = CrimeApplication.create(
      usn: 123,
      status: 'in_progress',
      client_has_partner: 'no',
      declaration_signed: true,
      date_stamp: nil,
    )

    client = Applicant.create(
      crime_application: app,
      first_name: 'John',
      last_name: 'Doe',
      date_of_birth: 25.years.ago,
      has_nino: 'yes',
      nino: 'AB123456A',
      telephone_number: '123456789',
      correspondence_address_type: 'home_address',
      passporting_benefit: true,
    )

    HomeAddress.create(
      person: client,
      address_line_one: '10, PRIME MINISTER & FIRST LORD OF THE TREASURY',
      address_line_two: 'DOWNING STREET',
      city: 'LONDON',
      country: 'UNITED KINGDOM',
      postcode: 'SW1A 2AA',
      lookup_id: '23747771',
    )

    kase = Case.create(
      crime_application: app,
      urn: '12345ABC',
      case_type: 'either_way',
      has_codefendants: 'yes',
      hearing_court_name: 'Manchester Crown Court',
      hearing_date: 1.year.from_now
    )

    Charge.create(
      case: kase,
      offence_name: 'Robbery',
      offence_dates: [OffenceDate.new(date: '01-02-2000')]
    )

    Codefendant.create(
      case: kase,
      first_name: 'Jane',
      last_name: 'Doe',
      conflict_of_interest: 'yes',
    )

    Ioj.create(
      case: kase,
      types: ['loss_of_liberty'],
      loss_of_liberty_justification: 'Details about loss of liberty.',
    )
  end

  after :all do
    # do not leave left overs in the test database
    CrimeApplication.destroy_all
  end

  before do
    stub_request(:post, 'http://datastore-webmock/api/v1/applications')
      .to_return(status: 201, body: '{}')
  end

  describe '#call' do
    let(:submitted_date) { DateTime.new(2022, 12, 31) }

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

      before do
        allow(crime_application).to receive(:date_stamp).and_return(date_stamp)
      end

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
      before do
        subject.call
      end

      it 'generates a valid JSON document conforming to the schema' do
        expect(
          LaaCrimeSchemas::Validator.new(payload)
        ).to be_valid
      end

      it 'calls the API and submits the serialized application' do
        expect(
          a_request(
            :post, 'http://datastore-webmock/api/v1/applications'
          ).with(body: { application: payload })
        ).to have_been_made.once
      end
    end
  end
end
