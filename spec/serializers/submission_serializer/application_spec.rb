require 'rails_helper'

RSpec.describe SubmissionSerializer::Application do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double CrimeApplication }

  describe '#sections' do
    it 'has all of the correct sections' do
      sections = [SubmissionSerializer::Sections::ApplicationDetails,
                  SubmissionSerializer::Sections::ProviderDetails,
                  SubmissionSerializer::Sections::ClientDetails,
                  SubmissionSerializer::Sections::CaseDetails,
                  SubmissionSerializer::Sections::IojDetails,]

      expect(subject.sections.map(&:class)).to match_array(sections)
    end
  end
end
