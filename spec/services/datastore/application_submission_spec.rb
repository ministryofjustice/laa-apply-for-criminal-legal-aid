require 'rails_helper'

RSpec.describe Datastore::ApplicationSubmission do
  #
  # NOTE: we are using real DB records here as a way of testing
  # an end to end full serialized application posted to the datastore.
  #
  subject { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.find_by(usn: 123) }
  let(:payload) { subject.application_payload }

  before :all do
    # create all neccessary records
    app = create_test_application(
      usn: 123,
      provider_email: 'foo@bar.com',
      legal_rep_first_name: 'John',
      legal_rep_last_name: 'Doe',
      legal_rep_telephone: '123456789',
    )

    client = Applicant.create(
      crime_application: app,
      first_name: 'John',
      last_name: 'Doe',
      date_of_birth: 25.years.ago,
      nino: 'AB123456A',
      benefit_type: 'universal_credit',
      telephone_number: '123456789',
      correspondence_address_type: 'home_address',
      benefit_check_result: true,
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
      has_case_concluded: 'yes',
      date_case_concluded: 1.year.ago,
      is_preorder_work_claimed: 'yes',
      preorder_work_date: 1.year.ago,
      preorder_work_details: 'preorder work details test',
      is_client_remanded: 'yes',
      date_client_remanded: 1.year.ago,
      case_type: 'either_way',
      has_codefendants: 'yes',
      hearing_court_name: 'Manchester Crown Court',
      hearing_date: 1.year.from_now
    )

    Charge.create(
      case: kase,
      offence_name: 'Attempt robbery',
      offence_dates: [OffenceDate.new(date_from: '01-02-2000')]
    )

    # An incomplete charge (no dates), on purpose
    # The serializer should filter/skip it
    Charge.create(
      case: kase,
      offence_name: 'Common assault',
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

    Income.create(
      crime_application: app,
      income_above_threshold: 'yes'
    )

    Outgoings.create(
      crime_application: app,
      outgoings_more_than_income: 'no'
    )

    Capital.create(
      crime_application: app,
      has_premium_bonds: 'no',
      will_benefit_from_trust_fund: 'no'
    )
  end

  after :all do
    # do not leave left overs in the test database
    CrimeApplication.destroy_all
  end

  before do
    allow(crime_application).to receive(:destroy!)

    stub_request(:post, 'http://datastore-webmock/api/v1/applications')
      .to_return(status: 201, body: '{}')
  end

  describe '#call' do
    let(:submitted_date) { DateTime.new(2022, 12, 31) }

    before do
      travel_to submitted_date
    end

    context 'when `date_stamp` attribute is `nil`' do
      it 'sets the `date_stamp` as the value of the submission date' do
        expect(
          crime_application
        ).to receive(:assign_attributes).with(
          submitted_at: submitted_date,
          date_stamp: submitted_date,
        )

        expect(subject.call).to be(true)
      end
    end

    context 'when there is already a `date_stamp`' do
      let(:date_stamp) { DateTime.new(2022, 12, 15) }

      before do
        allow(crime_application).to receive(:date_stamp).and_return(date_stamp)
      end

      it 'does not change the `date_stamp` value' do
        expect(
          crime_application
        ).to receive(:assign_attributes).with(
          submitted_at: submitted_date,
          date_stamp: date_stamp,
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

      # This test is redundant as we have the one above, but is a quick
      # way to see in the logs why exactly the validation is failing
      it 'has no schema errors' do
        expect(
          LaaCrimeSchemas::Validator.new(payload).fully_validate
        ).to be_empty
      end

      it 'calls the API and submits the serialized application' do
        expect(
          a_request(
            :post, 'http://datastore-webmock/api/v1/applications'
          ).with(body: { application: payload })
        ).to have_been_made.once
      end

      it 'purges the application from the local database' do
        expect(crime_application).to have_received(:destroy!)
      end
    end

    context 'handling of errors' do
      before do
        stub_request(:post, 'http://datastore-webmock/api/v1/applications')
          .to_raise(StandardError)

        allow(Rails.error).to receive(:report)

        subject.call
      end

      it 'does not purge the application from the local database' do
        expect(crime_application).not_to have_received(:destroy!)
      end

      it 'does not change any attributes of the application' do
        expect(crime_application.reload.date_stamp).to be_nil
        expect(crime_application.reload.submitted_at).to be_nil
        expect(crime_application.reload.status).to eq('in_progress')
      end

      it 'reports the exception, and redirect to the error page' do
        expect(Rails.error).to have_received(:report).with(
          an_instance_of(StandardError), hash_including(handled: true)
        )
      end
    end
  end
end
