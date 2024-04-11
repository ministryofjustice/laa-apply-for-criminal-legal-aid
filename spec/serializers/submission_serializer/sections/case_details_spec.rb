require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::CaseDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, case: kase) }
  let(:case_concluded_date) { DateTime.new(2023, 3, 2) }
  let(:client_remand_date) { DateTime.new(2023, 3, 2) }
  let(:preorder_work_date) { DateTime.new(2023, 3, 2) }

  let(:kase) do
    instance_double(
      Case,
      urn: '12345',
      case_type: case_type,
      has_case_concluded: 'yes',
      date_case_concluded: case_concluded_date,
      is_preorder_work_claimed: 'yes',
      preorder_work_date: client_remand_date,
      preorder_work_details: 'preorder_work_details',
      is_client_remanded: 'yes',
      date_client_remanded: client_remand_date,
      appeal_maat_id: '123',
      appeal_lodged_date: appeal_lodged_date,
      appeal_original_app_submitted: 'yes',
      appeal_financial_circumstances_changed: 'yes',
      appeal_reference_number: '',
      appeal_usn: '',
      appeal_with_changes_details: 'appeal changes',
      hearing_court_name: 'Court',
      hearing_date: hearing_date,
      is_first_court_hearing: 'no',
      first_court_hearing_name: 'First court',
      charges: double(complete: []), # `charges` serialisation tested in `definitions/offence_spec.rb`
      codefendants: [], # `codefendants` serialisation tested in `definitions/codefendant_spec.rb`
    )
  end

  let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }
  let(:appeal_lodged_date) { DateTime.new(2021, 5, 8) }
  let(:hearing_date) { DateTime.new(2023, 3, 2) }

  let(:json_output) do
    {
      case_details: {
        urn: '12345',
        case_type: case_type,
        has_case_concluded: 'yes',
        date_case_concluded: case_concluded_date,
        is_preorder_work_claimed: 'yes',
        preorder_work_date: client_remand_date,
        preorder_work_details: 'preorder_work_details',
        is_client_remanded: 'yes',
        date_client_remanded: client_remand_date,
        appeal_maat_id: '123',
        appeal_lodged_date: appeal_lodged_date,
        appeal_with_changes_details: 'appeal changes',
        appeal_original_app_submitted: 'yes',
        appeal_financial_circumstances_changed: 'yes',
        appeal_reference_number: '',
        appeal_usn: '',
        hearing_court_name: 'Court',
        hearing_date: hearing_date,
        is_first_court_hearing: 'no',
        first_court_hearing_name: 'First court',
        offences: [],
        codefendants: []
      }
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
