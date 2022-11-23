require 'rails_helper'

RSpec.describe Steps::Case::CaseTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      case_type:,
      appeal_maat_id:,
      appeal_with_changes_maat_id:,
      appeal_with_changes_details:
    }
  end

  let(:crime_application) do
    instance_double(CrimeApplication, date_stamp: nil, case: kase)
  end

  let(:kase) { Case.new }
  let(:case_type) { nil }
  let(:appeal_maat_id) { nil }
  let(:appeal_with_changes_maat_id) { nil }
  let(:appeal_with_changes_details) { nil }

  describe '#save' do
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

    context 'when `case_type` is valid' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:case_type, :invalid)).to be(false)
      end

      context 'when non-appeal case type' do
        context 'with a previous MAAT ID' do
          let(:appeal_maat_id) { '123456' }
          let(:appeal_with_changes_maat_id) { '234567' }

          it { is_expected.to be_valid }

          it 'can make MAAT ID fields nil if case types do not require them' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['appeal_maat_id']).to be_nil
            expect(attributes['appeal_with_changes_maat_id']).to be_nil
          end
        end

        context 'with details of a change of financial circumstances' do
          let(:appeal_with_changes_details) { 'These are the details' }

          it 'can financial change details nil if case type doesnt require it' do
            attributes = form.send(:attributes_to_reset)
            expect(form).to be_valid
            expect(attributes['appeal_with_changes_details']).to be_nil
          end
        end
      end

      context 'when Appeal to crown court' do
        context 'with a previous MAAT ID' do
          let(:case_type) { 'appeal_to_crown_court' }
          let(:appeal_maat_id) { '123456' }

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :appeal_maat_id,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset MAAT IDs as the are relevant to this case type' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['appeal_maat_id']).to eq(appeal_maat_id)
          end
        end

        context 'without a previous MAAT ID' do
          let(:case_type) { 'appeal_to_crown_court' }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :appeal_maat_id,
                :present
              )
            ).to be(false)
          end
        end
      end

      context 'when Appeal to crown court with changes in financial circumstances' do
        context 'with details of what has changed' do
          let(:case_type) { 'appeal_to_crown_court_with_changes' }
          let(:appeal_with_changes_maat_id) { '123456' }
          let(:appeal_with_changes_details) { 'These are the details' }

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :appeal_with_changes_details,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset MAAT IDs as the are relevant to this case type' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['appeal_with_changes_maat_id']).to eq(appeal_with_changes_maat_id)
          end

          it 'cannot reset change details as the are relevant to this case type' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['appeal_with_changes_details']).to eq(appeal_with_changes_details)
          end
        end

        context 'with no details of what has changed' do
          let(:case_type) { 'appeal_to_crown_court_with_changes' }
          let(:appeal_maat_id) { '123456' }

          it 'is invalid' do
            expect(form).not_to be_valid
            expect(
              form.errors.of_kind?(
                :appeal_with_changes_details,
                :blank
              )
            ).to be(true)
          end
        end
      end
    end

    context 'when validations pass' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'case_type' => CaseType::INDICTABLE,
                        'appeal_maat_id' => nil,
                        'appeal_with_changes_maat_id' => nil,
                        'appeal_with_changes_details' => nil
                      }
    end
  end
end
