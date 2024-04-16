require 'rails_helper'

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

  let(:crime_application) { instance_double(CrimeApplication, case: case_record) }
  let(:case_record) { Case.new(case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s) }

  let(:appeal_reference_number) { nil }
  let(:appeal_maat_id) { nil }
  let(:appeal_usn) { nil }

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
            'appeal_usn' => appeal_usn,
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
