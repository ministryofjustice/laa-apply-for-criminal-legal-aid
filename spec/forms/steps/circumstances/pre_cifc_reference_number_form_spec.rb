require 'rails_helper'

RSpec.describe Steps::Circumstances::PreCifcReferenceNumberForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      pre_cifc_reference_number:,
      pre_cifc_maat_id:,
      pre_cifc_usn:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:pre_cifc_reference_number) { nil }
  let(:pre_cifc_maat_id) { nil }
  let(:pre_cifc_usn) { nil }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:pre_cifc_reference_number) }
    it { is_expected.not_to validate_presence_of(:pre_cifc_maat_id) }
    it { is_expected.not_to validate_presence_of(:pre_cifc_usn) }

    context 'with invalid MAAT ID' do
      it 'has validation error' do
        ['X123Z', '12345', '1234567890', '1 2 3 4 5 6 7 8'].each do |test_case|
          args = {
            crime_application: crime_application,
            pre_cifc_maat_id: test_case,
            pre_cifc_reference_number: 'pre_cifc_maat_id',
          }

          form_object = described_class.new(**args)

          expect(form_object).not_to be_valid
          expect(form_object.errors.of_kind?(:pre_cifc_maat_id, :invalid)).to be(true)
        end
      end
    end
  end

  describe '#save' do
    context 'when MAAT ID is selected' do
      let(:pre_cifc_reference_number) { 'pre_cifc_maat_id' }
      let(:pre_cifc_maat_id) { '12345678' }

      it 'updates the record' do
        expect(crime_application).to receive(:update).with(
          {
            'pre_cifc_reference_number' => pre_cifc_reference_number,
            'pre_cifc_maat_id' => pre_cifc_maat_id,
            'pre_cifc_usn' => nil,
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when USN is selected' do
      let(:pre_cifc_reference_number) { 'pre_cifc_usn' }
      let(:pre_cifc_usn) { '12345678' }

      it 'updates the record' do
        expect(crime_application).to receive(:update).with(
          {
            'pre_cifc_reference_number' => pre_cifc_reference_number,
            'pre_cifc_maat_id' => nil,
            'pre_cifc_usn' => pre_cifc_usn
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
