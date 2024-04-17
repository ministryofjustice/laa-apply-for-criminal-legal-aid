require 'rails_helper'

RSpec.describe Steps::Client::AppealFinancialCircumstancesForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      appeal_financial_circumstances_changed:,
      appeal_with_changes_details:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: case_record) }
  let(:case_record) { Case.new(case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s) }

  let(:appeal_financial_circumstances_changed) { nil }
  let(:appeal_with_changes_details) { nil }

  describe '#save' do
    context 'when `appeal_financial_circumstances_changed` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:appeal_financial_circumstances_changed, :inclusion)).to be(true)
      end
    end

    context 'when yes is selected' do
      let(:appeal_financial_circumstances_changed) { YesNoAnswer::YES }

      context 'when `appeal_with_changes_details` is not provided' do
        it 'returns false' do
          expect(form.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:appeal_with_changes_details, :blank)).to be(true)
        end
      end

      context 'when `appeal_with_changes_details` is provided' do
        let(:appeal_with_changes_details) { 'Ch ch ch ch changes' }

        it { is_expected.to be_valid }

        it 'updates the record and resets the appeal reference attributes' do
          expect(case_record).to receive(:update).with(
            {
              'appeal_financial_circumstances_changed' => appeal_financial_circumstances_changed,
              'appeal_with_changes_details' => appeal_with_changes_details,
              'appeal_maat_id' => nil,
              'appeal_usn' => nil,
              'appeal_reference_number' => nil
            }
          ).and_return(true)

          expect(form.save).to be(true)
        end
      end
    end

    context 'when no is selected' do
      let(:appeal_financial_circumstances_changed) { YesNoAnswer::NO }

      it { is_expected.to be_valid }

      it 'updates the record and does not reset the appeal reference attributes' do
        expect(case_record).to receive(:update).with(
          {
            'appeal_financial_circumstances_changed' => appeal_financial_circumstances_changed,
            'appeal_with_changes_details' => nil,
          }
        ).and_return(true)

        expect(form.save).to be(true)
      end
    end
  end
end
