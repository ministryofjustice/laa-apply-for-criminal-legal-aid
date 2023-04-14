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
    let(:parent_ioj) { Ioj.new(types: ['foobar']) }

    before do
      allow(subject.parent).to receive(:ioj).and_return(parent_ioj)
    end

    it 're-hydrates the new application using the parent details' do
      expect(
        crime_application
      ).to receive(:update!).with(
        client_has_partner: YesNoAnswer::NO,
        parent_id: '47a93336-7da6-48ec-b139-808ddd555a41',
        date_stamp: an_instance_of(DateTime),
        ioj_passport: an_instance_of(Array),
        applicant: an_instance_of(Applicant),
        case: an_instance_of(Case),
      )

      expect(
        Ioj
      ).to receive(:new).with(
        hash_including('types' => ['foobar'])
      ).and_call_original

      expect(subject.call).to be(true)
    end

    context 'for a split case passported application' do
      let(:parent) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned_split_case').read) }
      let(:parent_ioj) { nil }

      it 'sets the `passport_override` flag on the Ioj record' do
        expect(
          Ioj
        ).to receive(:new).with(
          passport_override: true
        )

        expect(subject.call).to be(true)
      end
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
