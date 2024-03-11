require 'rails_helper'

RSpec.describe SubmissionSerializer::Application do
  subject { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.new(application_type:) }
  let(:application_type) { 'initial' }

  describe '#sections' do
    before do
      allow_any_instance_of(
        SubmissionSerializer::Sections::BaseSection
      ).to receive(:generate?).and_return(true)
    end

    it 'has the right sections in the right order' do
      expect(
        subject.sections
      ).to match_instances_array(
        [
          SubmissionSerializer::Sections::ApplicationDetails,
          SubmissionSerializer::Sections::ProviderDetails,
          SubmissionSerializer::Sections::ClientDetails,
          SubmissionSerializer::Sections::CaseDetails,
          SubmissionSerializer::Sections::IojDetails,
          SubmissionSerializer::Sections::MeansDetails,
          SubmissionSerializer::Sections::SupportingEvidence,
        ]
      )
    end

    context 'when an PSE application' do
      let(:application_type) { 'post_submission_evidence' }

      it 'has the right sections in the right order' do
        expect(
          subject.sections
        ).to match_instances_array(
          [
            SubmissionSerializer::Sections::PseApplicationDetails,
            SubmissionSerializer::Sections::ProviderDetails,
            SubmissionSerializer::Sections::ClientDetails,
            SubmissionSerializer::Sections::SupportingEvidence
          ]
        )
      end
    end
  end

  describe '#generate' do
    # NOTE: as we test each serializer individually, we don't
    # need to test again the output of a whole application,
    # we can use simplified doubles with the absolute minimum
    # and do a sanity check / smoke test on the result.
    # There is a full serialization test with real DB records
    # in spec `services/application_submission_spec.rb`

    let(:kase) { Case.new }
    let(:income) { Income.new }
    let(:capital) { Capital.new }
    let(:documents_scope) { double(stored: [Document.new]) }

    before do
      allow(crime_application).to receive_messages(case: kase, documents: documents_scope,
                                                   income: income, capital: capital)
    end

    it 'generates a serialized version of the application' do
      expect(
        subject.generate
      ).to match(
        a_hash_including(
          'schema_version' => 1.0,
          'ioj_passport' => be_an(Array),
          'means_passport' => be_an(Array),
          'provider_details' => be_a(Hash),
          'client_details' => a_hash_including('applicant'),
          'case_details' => a_hash_including('offences' => [], 'codefendants' => []),
          'interests_of_justice' => [],
          'means_details' => a_hash_including('income_details', 'capital_details'),
          'supporting_evidence' => be_an(Array),
        )
      )
    end
  end
end
