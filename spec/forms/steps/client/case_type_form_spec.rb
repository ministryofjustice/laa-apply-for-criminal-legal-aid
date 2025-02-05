require 'rails_helper'

RSpec.describe Steps::Client::CaseTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: case_record,
      case_type: case_type,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: case_record) }
  let(:case_record) { Case.new }

  let(:case_type) { CaseType::INDICTABLE.to_s }

  describe 'validations' do
    context 'when `case_type` is blank' do
      let(:case_type) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:case_type, :inclusion)).to be(true)
      end
    end

    context 'when `case_type` is invalid' do
      let(:case_type) { 'invalid_type' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:case_type, :inclusion)).to be(true)
      end
    end

    context 'when `case_type` is `appeal to Crown Court with changes`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:case_type, :inclusion)).to be(true)
      end
    end

    context 'when `case_type` is valid' do
      it { is_expected.to be_valid }
    end
  end

  describe '#save' do
    before do
      allow(case_record).to receive(:case_type).and_return(previous_case_type)
    end

    context 'when the case type has changed' do
      let(:previous_case_type) { CaseType::SUMMARY_ONLY.to_s }

      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'case_type' => CaseType::INDICTABLE,
                        :appeal_lodged_date => nil,
                        :appeal_original_app_submitted => nil,
                        :appeal_financial_circumstances_changed => nil,
                        :appeal_with_changes_details => nil,
                        :appeal_reference_number => nil,
                        :appeal_maat_id => nil,
                        :appeal_usn => nil,
                      }
    end

    context 'when case type is the same as in the persisted record' do
      let(:previous_case_type) { CaseType::INDICTABLE.to_s }

      it 'does not save the record but returns true' do
        expect(case_record).not_to receive(:update)
        expect(subject.save).to be(true)
      end
    end
  end
end
