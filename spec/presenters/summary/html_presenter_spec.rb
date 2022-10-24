require 'rails_helper'

describe Summary::HtmlPresenter do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(CrimeApplication, applicant: double, case: kase)
  end

  let(:kase) { instance_double(Case, ioj:) }

  let(:ioj) { instance_double(Ioj) }

  describe '#sections' do
    before do
      allow_any_instance_of(
        Summary::Sections::BaseSection
      ).to receive(:show?).and_return(true)
    end

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
          Summary::Sections::JustificationForLegalAid,
        ]
      )
    end
  end
end
