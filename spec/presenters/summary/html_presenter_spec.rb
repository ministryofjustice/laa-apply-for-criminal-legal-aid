require 'rails_helper'

# This spec is just a high level, smoke test of the sections.
# It is not intended to test conditionality or complex rules,
# as that is tested individually in each of the sections specs.
#
describe Summary::HtmlPresenter do
  subject(:presenter) { described_class.new(crime_application:) }

  let(:database_application) do
    instance_double(CrimeApplication, applicant: double, case: double, ioj: double, status: :in_progress,
                    income: double, outgoings: double, documents: double, application_type: application_type)
  end

  let(:datastore_application) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge('application_type' => application_type)
  end

  describe '#sections' do
    subject(:sections) { presenter.sections.map { |s| s.class.name.demodulize } }

    before do
      allow_any_instance_of(
        Summary::Sections::BaseSection
      ).to receive(:show?).and_return(true)
    end

    context 'when an initial application' do
      let(:application_type) { 'initial' }

      context 'for an "in progress" database application' do
        let(:crime_application) { database_application }

        let(:expected_sections) do
          %w[
            ClientDetails
            ContactDetails
            CaseDetails
            Offences
            Codefendants
            NextCourtHearing
            FirstCourtHearing
            JustificationForLegalAid
            PassportJustificationForLegalAid
            EmploymentDetails
            IncomeDetails
            OtherIncomeDetails
            HousingPayments
            OtherOutgoingsDetails
            SupportingEvidence
          ]
        end

        it { is_expected.to match_array(expected_sections) }
      end

      context 'for a "submitted" datastore application' do
        let(:crime_application) { datastore_application }

        let(:expected_sections) do
          %w[
            Overview
            ClientDetails
            ContactDetails
            CaseDetails
            Offences
            Codefendants
            NextCourtHearing
            FirstCourtHearing
            JustificationForLegalAid
            PassportJustificationForLegalAid
            EmploymentDetails
            IncomeDetails
            OtherIncomeDetails
            HousingPayments
            OtherOutgoingsDetails
            SupportingEvidence
            LegalRepresentativeDetails
          ]
        end

        it { is_expected.to match_array(expected_sections) }
      end
    end

    context 'when a PSE application' do
      let(:application_type) { 'post_submission_evidence' }

      context 'for an "in progress" database application' do
        let(:crime_application) { database_application }
        let(:expected_sections) { %w[ClientDetails SupportingEvidence] }

        it { is_expected.to match_array(expected_sections) }
      end

      context 'for a "submitted" datastore application' do
        let(:crime_application) { datastore_application }

        let(:expected_sections) do
          %w[
            Overview
            ClientDetails
            SupportingEvidence
            LegalRepresentativeDetails
          ]
        end

        it { is_expected.to match_array(expected_sections) }
      end
    end
  end
end
