require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::CaseDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, case: kase) }

  let(:kase) do
    instance_double(
      Case,
      urn: '12345',
      case_type: 'Indictable',
      appeal_maat_id: 1,
      appeal_with_changes_maat_id: 2,
      appeal_with_changes_details: 'appeal changes',
      hearing_court_name: 'Court',
      hearing_date: hearing_date,
      charges: [charge1, charge2],
      codefendants: [codefendant],
    )
  end

  let(:hearing_date) { DateTime.new(2023, 3, 2) }

  let(:charge1) { Charge.new(offence_name: 'Common assault') }
  let(:charge2) { Charge.new(offence_name: 'An unlisted offence') }

  let(:codefendant) do
    Codefendant.new(
      first_name: 'Max',
      last_name: 'Mustermann',
      conflict_of_interest: 'yes',
    )
  end

  let(:json_output) do
    {
      case_details: {
        urn: '12345',
        case_type: 'Indictable',
        appeal_maat_id: 1,
        appeal_with_changes_maat_id: 2,
        appeal_with_changes_details: 'appeal changes',
        hearing_court_name: 'Court',
        hearing_date: hearing_date,
        offences: [
          {
            name: 'Common assault',
            offence_class: 'H',
            dates: %w[Date1 Date2],
          },
          {
            name: 'An unlisted offence',
            offence_class: nil,
            dates: %w[Date1],
          },
        ],
        codefendants: [
          {
            first_name: 'Max',
            last_name: 'Mustermann',
            conflict_of_interest: 'yes',
          }
        ]
      }
    }.as_json
  end

  before do
    allow(charge1).to receive(:offence_dates).and_return([{ date: 'Date1' }, { date: 'Date2' }])
    allow(charge2).to receive(:offence_dates).and_return([{ date: 'Date1' }])
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
