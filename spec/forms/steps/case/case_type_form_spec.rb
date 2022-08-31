require 'rails_helper'

RSpec.describe Steps::Case::CaseTypeForm do

  let(:arguments) { {
    crime_application: crime_application,
    case_type: case_type,
    previous_maat_id: previous_maat_id,
    cc_appeal_fin_change_details: cc_appeal_fin_change_details
  } }

  let(:crime_application) { 
    instance_double(CrimeApplication)
  }

  let(:case_type) { nil }
  let(:previous_maat_id) { nil }
  let(:cc_appeal_fin_change_details) { nil }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'when `case_type` is blank' do
      let(:case_type) { '' }

      it 'has is a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:case_type, :blank)).to eq(true)
      end
    end

    context 'when `case_type` is invalid' do
      let(:case_type) { 'invalid_type' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:case_type, :inclusion)).to eq(true)
      end
    end

    context 'when `case_type` is valid' do
      let(:case_type) { 'indictable' }
      it 'passes validation' do
        expect(subject).to be_valid
        expect(subject.errors.of_kind?(:case_type, :invalid)).to eq(false)
      end

      context 'non-appeal case type' do
        context 'with a previous MAAT ID' do
          let(:previous_maat_id) { '123456' }
          it 'is invalid' do
            expect(subject).to_not be_valid
            expect(
              subject.errors.of_kind?(
                :previous_maat_id, 
                :present)
            ).to eq(true)
          end
        end

        context 'with details of a change of financial circumstances' do
          let(:cc_appeal_fin_change_details) { 'These are the details' }
          it 'is invalid' do
            expect(subject).to_not be_valid
            expect(
              subject.errors.of_kind?(
                :cc_appeal_fin_change_details, 
                :present
              )).to eq(true)
          end
        end
      end

      context 'Appeal to crown court' do
        context 'with a previous MAAT ID' do
          let(:case_type) { 'cc_appeal' }
          let(:previous_maat_id) { '123456' }
          it 'is valid' do
            expect(subject).to be_valid
            expect(
              subject.errors.of_kind?(
                :previous_maat_id, 
                :present)
            ).to eq(false)
          end
        end

        context 'without a previous MAAT ID' do
          let(:case_type) { 'cc_appeal' }
          it 'is also valid' do
            expect(subject).to be_valid
            expect(
              subject.errors.of_kind?(
                :previous_maat_id, 
                :present)
            ).to eq(false)
          end
        end
      end

      context 'Appeal to crown court with changes in financial circumstances' do
        context 'with details of what has changed' do
          let(:case_type) { 'cc_appeal_fin_change' }
          let(:previous_maat_id) { '123456' }
          let(:cc_appeal_fin_change_details) { 'These are the details' }
          it 'is valid' do
            expect(subject).to be_valid
            expect(
              subject.errors.of_kind?(
                :cc_appeal_fin_change_details, 
                :present)
            ).to eq(false)
          end
        end

        context 'with no details of what has changed' do
          let(:case_type) { 'cc_appeal_fin_change' }
          let(:previous_maat_id) { '123456' }
          it 'is invalid' do
            expect(subject).to_not be_valid
            expect(
              subject.errors.of_kind?(
                :cc_appeal_fin_change_details, 
                :blank)
            ).to eq(true)
          end
        end
      end
    end

    context 'when validations pass' do
        let(:case_type) { 'indictable' }
        it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'case_type' => 'indictable',
                        'previous_maat_id' => nil,
                        'cc_appeal_fin_change_details' => nil
                      }
    end
  end
end
