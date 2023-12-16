require 'rails_helper'

# This spec is just a high level, smoke test of the sections.
# It is not intended to test conditionality or complex rules,
# as that is tested individually in each of the sections specs.
#
describe Summary::HtmlPresenter do
  subject { described_class.new(crime_application:) }

  describe '#sections' do
    before do
      allow_any_instance_of(
        Summary::Sections::BaseSection
      ).to receive(:show?).and_return(true)
    end

    context 'for a database application' do
      let(:crime_application) do
        instance_double(CrimeApplication, applicant: double, case: double, ioj: double, status: :in_progress,
                        income: double, documents: double)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'has the right sections in the right order' do
        expect(
          subject.sections
        ).to match_instances_array(
          [
            Summary::Sections::ClientDetails,
            Summary::Sections::ContactDetails,
            Summary::Sections::CaseDetails,
            Summary::Sections::Offences,
            Summary::Sections::Codefendants,
            Summary::Sections::NextCourtHearing,
            Summary::Sections::FirstCourtHearing,
            Summary::Sections::JustificationForLegalAid,
            Summary::Sections::PassportJustificationForLegalAid,
            Summary::Sections::EmploymentDetails,
            Summary::Sections::IncomeDetails,
            Summary::Sections::OtherIncomeDetails,
            Summary::Sections::SupportingEvidence,
          ]
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'for a completed application (API response)' do
      let(:crime_application) do
        JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'has the right sections in the right order' do
        expect(
          subject.sections
        ).to match_instances_array(
          [
            Summary::Sections::Overview,
            Summary::Sections::ClientDetails,
            Summary::Sections::ContactDetails,
            Summary::Sections::CaseDetails,
            Summary::Sections::Offences,
            Summary::Sections::Codefendants,
            Summary::Sections::NextCourtHearing,
            Summary::Sections::FirstCourtHearing,
            Summary::Sections::JustificationForLegalAid,
            Summary::Sections::PassportJustificationForLegalAid,
            Summary::Sections::EmploymentDetails,
            Summary::Sections::IncomeDetails,
            Summary::Sections::OtherIncomeDetails,
            Summary::Sections::SupportingEvidence,
            Summary::Sections::LegalRepresentativeDetails,
          ]
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
