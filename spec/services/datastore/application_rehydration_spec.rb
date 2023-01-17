require 'rails_helper'

RSpec.describe Datastore::ApplicationRehydration do
  subject { described_class.new(crime_application, parent:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant:
    )
  end

  let(:applicant) { nil }
  let(:parent) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read) }

  before do
    allow(crime_application).to receive(:update!).and_return(true)
  end

  describe '#call' do
    it 're-hydrates the new application using the parent details' do
      expect(
        crime_application
      ).to receive(:update!).with(
        client_has_partner: YesNoAnswer::NO,
        date_stamp: an_instance_of(DateTime),
        ioj_passport: an_instance_of(Array),
        applicant: an_instance_of(Applicant),
        case: an_instance_of(Case),
      )

      expect(subject.call).to be(true)
    end

    context 'for an already re-hydrated application' do
      let(:applicant) { 'something' }

      it 'skips the re-hydration, to avoid overwriting any details' do
        expect(crime_application).not_to receive(:update!)
        expect(subject.call).to be_nil
      end
    end
  end
end
