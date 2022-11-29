require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::CaseDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication) }

  let(:kase) do
    instance_double(
      Case,
      urn: '12345',
      appeal_maat_id: 1,
      appeal_with_changes_maat_id: 2,
      appeal_with_changes_details: 'appeal changes',
      hearing_court_name: 'Court',
      hearing_date: hearing_date,
      case_type: 'Indictable'
    )
  end

  let(:hearing_date) { DateTime.new(2023, 3, 2) }

  let(:offence) do
    Charge.new(
      offence_name: 'Common Assault',
    )
  end

  let(:codefendant) do
    Codefendant.new(
      first_name: 'Max',
      last_name: 'Mustermann',
      conflict_of_interest: 'Conflict of interest',
    )
  end

  let(:json_output) do
    {
      case_details: {
        urn: '12345',
        appeal_maat_id: 1,
        appeal_with_changes_maat_id: 2,
        appeal_with_changes_details: 'appeal changes',
        hearing_court_name: 'Court',
        hearing_date: hearing_date,
        case_type: 'Indictable',
        offences: [
          {
            name: 'Common Assault',
            offence_class: nil,
            dates: [],
          }
        ],
        codefendants: [
          {
            first_name: 'Max',
            last_name: 'Mustermann',
            conflict_of_interest: 'Conflict of interest',
          }
        ]
      }
    }.as_json
  end

  before do
    allow(crime_application).to receive(:case).and_return(kase)

    allow(kase).to receive(:charges).and_return([offence])

    allow(offence).to receive(:offence_dates).and_return([])

    allow(crime_application).to receive(:codefendants).and_return([codefendant])
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
