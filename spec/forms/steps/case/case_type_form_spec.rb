require 'rails_helper'

RSpec.describe Steps::Case::CaseTypeForm do

  let(:arguments) { {
    crime_application: crime_application,
    case_type: case_type,
    cc_appeal_maat_id: cc_appeal_maat_id,
    cc_appeal_fin_change_maat_id: cc_appeal_fin_change_maat_id,
    cc_appeal_fin_change_details: cc_appeal_fin_change_details
  } }

  let(:crime_application) {
    instance_double(CrimeApplication, date_stamp: nil, case: kase)
  }

  let(:kase) { Case.new }

  let(:case_type) { nil }
  let(:cc_appeal_maat_id) { nil }
  let(:cc_appeal_fin_change_maat_id) { nil }
  let(:cc_appeal_fin_change_details) { nil }

  subject { described_class.new(arguments) }

  describe '#save' do
    describe 'date stamping' do
      let(:kase) { instance_double(Case) }

      after { subject.save }

      context 'when case is valid' do
        before { expect(kase).to receive(:update) { true } }

        context 'and `case_type` is "date stampable"' do
          let(:case_type) { 'summary_only' }

          it 'the crime application date stamp is set' do
            expect(crime_application).to receive(:update).with(hash_including(:date_stamp))
          end
        end

        context 'and `case_type` is not "date stampable"' do
          let(:case_type) { 'indictable' }

          it 'the crime application date stamp is not set' do
            expect(crime_application).not_to receive(:update).with(hash_including(:date_stamp))
          end
        end
      end

      context 'when case_type is not valid' do
        before { expect(kase).to receive(:update) { false } }

        context 'and `case_type` is "date stampable"' do
          let(:case_type) { 'summary_only' }

          it 'the crime application date stamp is not set' do
            expect(crime_application).not_to receive(:update).with(hash_including(:date_stamp))
          end
        end
      end
    end

    context 'when `case_type` is blank' do
      let(:case_type) { '' }

      it 'has is a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:case_type, :inclusion)).to eq(true)
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
          let(:cc_appeal_maat_id) { '123456' }
          let(:cc_appeal_fin_change_maat_id) { '234567' }
          it 'can make MAAT ID fields nil if case types do not require them' do
            attributes = subject.send(:attributes_to_reset)
            expect(subject).to be_valid
            expect(attributes['cc_appeal_maat_id']).to be(nil)
            expect(attributes['cc_appeal_fin_change_maat_id']).to be(nil)
          end
        end

        context 'with details of a change of financial circumstances' do
          let(:cc_appeal_fin_change_details) { 'These are the details' }
          it 'can financial change details nil if case type doesnt require it' do
            attributes = subject.send(:attributes_to_reset)
            expect(subject).to be_valid
            expect(attributes['cc_appeal_fin_change_details']).to be(nil)
          end
        end
      end

      context 'Appeal to crown court' do
        context 'with a previous MAAT ID' do
          let(:case_type) { 'cc_appeal' }
          let(:cc_appeal_maat_id) { '123456' }
          it 'is valid' do
            expect(subject).to be_valid
            expect(
              subject.errors.of_kind?(
                :cc_appeal_maat_id,
                :present)
            ).to eq(false)
          end

          it 'cannot reset MAAT IDs as the are relevant to this case type' do
            attributes = subject.send(:attributes_to_reset)
            expect(attributes['cc_appeal_maat_id']).to eq(cc_appeal_maat_id)
          end
        end

        context 'without a previous MAAT ID' do
          let(:case_type) { 'cc_appeal' }
          it 'is also valid' do
            expect(subject).to be_valid
            expect(
              subject.errors.of_kind?(
                :cc_appeal_maat_id,
                :present)
            ).to eq(false)
          end
        end
      end

      context 'Appeal to crown court with changes in financial circumstances' do
        context 'with details of what has changed' do
          let(:case_type) { 'cc_appeal_fin_change' }
          let(:cc_appeal_fin_change_maat_id) { '123456' }
          let(:cc_appeal_fin_change_details) { 'These are the details' }
          it 'is valid' do
            expect(subject).to be_valid
            expect(
              subject.errors.of_kind?(
                :cc_appeal_fin_change_details,
                :present)
            ).to eq(false)
          end

          it 'cannot reset MAAT IDs as the are relevant to this case type' do
            attributes = subject.send(:attributes_to_reset)
            expect(attributes['cc_appeal_fin_change_maat_id']).to eq(cc_appeal_fin_change_maat_id)
          end

          it 'cannot reset change details as the are relevant to this case type' do
            attributes = subject.send(:attributes_to_reset)
            expect(attributes['cc_appeal_fin_change_details']).to eq(cc_appeal_fin_change_details)
          end
        end

        context 'with no details of what has changed' do
          let(:case_type) { 'cc_appeal_fin_change' }
          let(:cc_appeal_maat_id) { '123456' }
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
                        'case_type' => CaseType::INDICTABLE,
                        'cc_appeal_maat_id' => nil,
                        'cc_appeal_fin_change_maat_id' => nil,
                        'cc_appeal_fin_change_details' => nil
                      }
    end
  end
end
