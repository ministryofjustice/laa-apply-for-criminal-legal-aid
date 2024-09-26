require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers

RSpec.describe SubmissionSerializer::Sections::CaseDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, kase: kase, non_means_tested?: non_means_tested) }
  let(:case_concluded_date) { DateTime.new(2023, 3, 2) }
  let(:client_remand_date) { DateTime.new(2023, 3, 2) }
  let(:preorder_work_date) { DateTime.new(2023, 3, 4) }
  let(:non_means_tested) { false }

  let(:kase) do
    instance_double(
      Case,
      urn: '12345',
      case_type: case_type,
      has_case_concluded: 'yes',
      date_case_concluded: case_concluded_date,
      is_preorder_work_claimed: 'yes',
      preorder_work_date: preorder_work_date,
      preorder_work_details: 'preorder_work_details',
      is_client_remanded: 'yes',
      date_client_remanded: client_remand_date,
      appeal_maat_id: '123',
      appeal_lodged_date: appeal_lodged_date,
      appeal_original_app_submitted: 'yes',
      appeal_financial_circumstances_changed: appeal_financial_circumstances_changed,
      appeal_reference_number: '',
      appeal_usn: '',
      appeal_with_changes_details: 'appeal changes',
      hearing_court_name: 'Court',
      hearing_date: hearing_date,
      is_first_court_hearing: 'no',
      first_court_hearing_name: 'First court',
      charges: double(complete: []), # `charges` serialisation tested in `definitions/offence_spec.rb`
      codefendants: [], # `codefendants` serialisation tested in `definitions/codefendant_spec.rb`
      client_other_charge_in_progress: 'no',
      partner_other_charge_in_progress: 'no',
      client_other_charge: nil, # `client_other_charge` serialisation tested in `definitions/other_charge_spec.rb`
      partner_other_charge: nil # `partner_other_charge` serialisation tested in `definitions/other_charge_spec.rb`
    )
  end

  let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }
  let(:appeal_lodged_date) { DateTime.new(2021, 5, 8) }
  let(:hearing_date) { DateTime.new(2023, 3, 2) }
  let(:appeal_financial_circumstances_changed) { 'yes' }

  let(:json_output) do
    {
      case_details: {
        urn: '12345',
        case_type: case_type,
        has_case_concluded: 'yes',
        date_case_concluded: case_concluded_date,
        is_preorder_work_claimed: 'yes',
        preorder_work_date: preorder_work_date,
        preorder_work_details: 'preorder_work_details',
        is_client_remanded: 'yes',
        date_client_remanded: client_remand_date,
        appeal_maat_id: '123',
        appeal_lodged_date: appeal_lodged_date,
        appeal_with_changes_details: 'appeal changes',
        appeal_original_app_submitted: 'yes',
        appeal_financial_circumstances_changed: appeal_financial_circumstances_changed,
        appeal_reference_number: '',
        appeal_usn: '',
        hearing_court_name: 'Court',
        hearing_date: hearing_date,
        is_first_court_hearing: 'no',
        first_court_hearing_name: 'First court',
        offences: [],
        codefendants: [],
        client_other_charge_in_progress: 'no',
        partner_other_charge_in_progress: 'no',
        client_other_charge: nil,
        partner_other_charge: nil
      }
    }.as_json
  end

  let(:non_means_tested_json_output) do
    {
      case_details: {
        urn: '12345',
        has_case_concluded: 'yes',
        date_case_concluded: case_concluded_date,
        is_preorder_work_claimed: 'yes',
        preorder_work_date: preorder_work_date,
        preorder_work_details: 'preorder_work_details',
        hearing_court_name: 'Court',
        hearing_date: hearing_date,
        is_first_court_hearing: 'no',
        first_court_hearing_name: 'First court',
        offences: [],
        codefendants: [],
        client_other_charge_in_progress: 'no',
        partner_other_charge_in_progress: 'no',
        client_other_charge: nil,
        partner_other_charge: nil
      }
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }

    context 'when non-means tested application' do
      let(:non_means_tested) { true }

      it { expect(subject.generate).to eq(non_means_tested_json_output) }
    end
  end

  describe '#case_type' do
    context 'when the case type is `appeal_to_crown_court`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      context 'when `appeal_financial_circumstances_changed==yes`' do
        let(:appeal_financial_circumstances_changed) { 'yes' }

        it 'returns the case type appeal_to_crown_court_with_changes' do
          expect(subject.send(:case_type)).to eq(CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s)
        end
      end

      context 'when `appeal_financial_circumstances_changed==no`' do
        let(:appeal_financial_circumstances_changed) { 'no' }

        it 'returns the case type appeal_to_crown_court' do
          expect(subject.send(:case_type)).to eq(CaseType::APPEAL_TO_CROWN_COURT.to_s)
        end
      end
    end

    context 'when the case type is not `appeal_to_crown_court`' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      it 'returns the case type appeal_to_crown_court' do
        expect(subject.send(:case_type)).to eq(CaseType::INDICTABLE.to_s)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
