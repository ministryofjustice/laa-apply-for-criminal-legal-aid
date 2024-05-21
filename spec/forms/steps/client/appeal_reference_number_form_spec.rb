require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Steps::Client::AppealReferenceNumberForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      appeal_reference_number:,
      appeal_maat_id:,
      appeal_usn:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: case_record, applicant: applicant_record) }
  let(:case_record) { Case.new(case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s) }
  let(:applicant_record) {
    instance_double(Applicant, home_address?: home_address?,
                                           correspondence_address?: correspondence_address?,
                                           home_address: home_address, correspondence_address: correspondence_address)
  }

  let(:appeal_reference_number) { nil }
  let(:appeal_maat_id) { nil }
  let(:appeal_usn) { nil }
  let(:home_address?) { false }
  let(:correspondence_address?) { false }
  let(:home_address) { instance_double(HomeAddress, destroy!: true) }
  let(:correspondence_address) { instance_double(CorrespondenceAddress, destroy!: true) }

  let(:applicant_attributes_to_reset) {
    {
      'residence_type' => nil,
      'correspondence_address_type' => nil,
      'telephone_number' => nil,
      'has_nino' => nil,
      'nino' => nil,
      'will_enter_nino' => nil,
      'benefit_type' => nil,
      'last_jsa_appointment_date' => nil,
      'benefit_check_result' => nil,
      'has_benefit_evidence' => nil
    }
  }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:appeal_reference_number) }

    it { is_expected.not_to validate_presence_of(:appeal_maat_id) }
    it { is_expected.not_to validate_presence_of(:appeal_usn) }

    context 'previous MAAT ID format' do
      context 'when `appeal_maat_id` is not numeric' do
        let(:appeal_maat_id) { 'X123Z' }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:appeal_maat_id, :invalid)).to be(true)
        end
      end

      context 'when `appeal_maat_id` is out of bounds' do
        context 'not enough digits' do
          let(:appeal_maat_id) { '12345' }

          it 'has a validation error on the field' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:appeal_maat_id, :invalid)).to be(true)
          end
        end

        context 'too many digits' do
          let(:appeal_maat_id) { '1234567890' }

          it 'has a validation error on the field' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:appeal_maat_id, :invalid)).to be(true)
          end
        end
      end
    end
  end

  describe '#save' do
    let(:home_address?) { true }
    let(:correspondence_address?) { true }

    before do
      allow(subject).to receive(:kase).and_return(case_record)
    end

    context 'when MAAT ID is selected' do
      let(:appeal_reference_number) { 'appeal_maat_id' }
      let(:appeal_maat_id) { '12345678' }

      it 'updates the record' do
        expect(case_record).to receive(:update).with(
          {
            'appeal_reference_number' => appeal_reference_number,
            'appeal_maat_id' => appeal_maat_id,
            'appeal_usn' => nil,
          }
        ).and_return(true)

        expect(applicant_record).to receive(:update).with(applicant_attributes_to_reset).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when USN is selected' do
      let(:appeal_reference_number) { 'appeal_usn' }
      let(:appeal_usn) { '12345678' }

      it 'updates the record' do
        expect(case_record).to receive(:update).with(
          {
            'appeal_reference_number' => appeal_reference_number,
            'appeal_maat_id' => nil,
            'appeal_usn' => appeal_usn
          }
        ).and_return(true)

        expect(applicant_record).to receive(:update).with(applicant_attributes_to_reset).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
