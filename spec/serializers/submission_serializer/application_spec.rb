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
          SubmissionSerializer::Sections::EvidenceDetails,
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
            SubmissionSerializer::Sections::EvidenceDetails,
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

    let(:json_output) do
      {
        id: nil,
        parent_id: nil,
        schema_version: 1.0,
        reference: nil,
        application_type: 'initial',
        created_at: nil,
        submitted_at: nil,
        date_stamp: nil,
        is_means_tested: nil,
        ioj_passport: [],
        means_passport: [],
        additional_information: nil,
        provider_details: {
          office_code: nil,
          provider_email: nil,
          legal_rep_has_partner_declaration: nil,
          legal_rep_no_partner_declaration_reason: nil,
          legal_rep_first_name: nil,
          legal_rep_last_name: nil,
          legal_rep_telephone: nil
        },
        interests_of_justice: [],
        evidence_details: {
          evidence_prompts: []
        },
        supporting_evidence: [],
        pre_cifc_reference_number: nil,
        pre_cifc_maat_id: nil,
        pre_cifc_usn: nil,
        pre_cifc_reason: nil,
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end
end
