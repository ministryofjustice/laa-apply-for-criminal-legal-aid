require 'rails_helper'

describe Summary::HtmlPresenter do
  subject { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication) }

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
        ]
      )
    end
  end
end
