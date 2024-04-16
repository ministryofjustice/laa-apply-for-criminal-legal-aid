require 'rails_helper'

RSpec.describe Steps::Client::AppealDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      appeal_lodged_date:,
      appeal_original_app_submitted:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: case_record) }
  let(:case_record) { Case.new(case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s) }

  let(:appeal_lodged_date) { nil }
  let(:appeal_original_app_submitted) { nil }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:appeal_lodged_date) }

    it_behaves_like 'a multiparam date validation',
                    attribute_name: :appeal_lodged_date,
                    allow_past: true, allow_future: false
  end

  describe '#save' do
    context 'when `appeal_lodged_date` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:appeal_lodged_date, :blank)).to be(true)
      end
    end

    context 'when `appeal_original_app_submitted` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:appeal_original_app_submitted, :inclusion)).to be(true)
      end
    end

    context 'when all args are provided' do
      let(:appeal_lodged_date) { Time.zone.today }
      let(:appeal_original_app_submitted) { YesNoAnswer::YES }

      it 'updates the record' do
        expect(case_record).to receive(:update).with(
          {
            'appeal_lodged_date' => appeal_lodged_date,
            'appeal_original_app_submitted' => appeal_original_app_submitted,
          }
        ).and_return(true)

        expect(form.save).to be(true)
      end
    end
  end
end
