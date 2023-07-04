require 'rails_helper'

RSpec.describe Steps::Case::AppealDetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      appeal_maat_id:,
      appeal_lodged_date:,
      appeal_with_changes_details:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: case_record) }
  let(:case_record) { Case.new(case_type:) }

  let(:case_type) { nil }
  let(:appeal_maat_id) { nil }
  let(:appeal_lodged_date) { nil }
  let(:appeal_with_changes_details) { nil }

  describe 'validations' do
    context 'when case type is `appeal_to_crown_court`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it { is_expected.to validate_presence_of(:appeal_lodged_date) }

      it { is_expected.not_to validate_presence_of(:appeal_with_changes_details) }
      it { is_expected.not_to validate_presence_of(:appeal_maat_id) }

      it_behaves_like 'a multiparam date validation',
                      attribute_name: :appeal_lodged_date,
                      allow_past: true, allow_future: false
    end

    context 'when case type is `appeal_to_crown_court_with_changes`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }
      let(:appeal_with_changes_details) { 'mandatory details' }

      it { is_expected.to validate_presence_of(:appeal_lodged_date) }
      it { is_expected.to validate_presence_of(:appeal_with_changes_details) }

      it { is_expected.not_to validate_presence_of(:appeal_maat_id) }

      it_behaves_like 'a multiparam date validation',
                      attribute_name: :appeal_lodged_date,
                      allow_past: true, allow_future: false
    end
  end

  describe '#save' do
    before do
      allow(subject).to receive(:kase).and_return(case_record)
    end

    let(:appeal_lodged_date) { Time.zone.today }
    let(:appeal_maat_id) { '12345678' }

    context 'when case type is `appeal_to_crown_court`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it 'updates the record' do
        expect(case_record).to receive(:update).with(
          {
            'appeal_maat_id' => appeal_maat_id,
            'appeal_lodged_date' => appeal_lodged_date,
            'appeal_with_changes_details' => nil,
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when case type is `appeal_to_crown_court_with_changes`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }
      let(:appeal_with_changes_details) { 'mandatory details' }

      it 'updates the record' do
        expect(case_record).to receive(:update).with(
          {
            'appeal_maat_id' => appeal_maat_id,
            'appeal_lodged_date' => appeal_lodged_date,
            'appeal_with_changes_details' => appeal_with_changes_details,
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
