require 'rails_helper'

RSpec.describe AppealDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(CrimeApplication, errors:, kase:) }
  let(:errors) { double(:errors, empty?: false) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { nil }

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when case type is nil' do
      let(:case_type) { nil }

      it { is_expected.to be false }
    end

    context 'when case type is not appeal' do
      let(:case_type) { CaseType::COMMITTAL.to_s }

      it { is_expected.to be false }
    end

    context 'when case type is appeal to Crown Court' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it { is_expected.to be true }
    end

    context 'when case type is appeal to Crown Court with changes' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }

      it { is_expected.to be true }
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }

    before do
      allow(kase).to receive_messages(
        appeal_lodged_date:,
        appeal_original_app_submitted:
      )
    end

    let(:appeal_lodged_date) { '2023-11-11' }
    let(:appeal_original_app_submitted) { 'yes' }

    context 'when a general details is missing' do
      let(:appeal_lodged_date) { nil }
      let(:appeal_original_app_submitted) { 'no' }

      it { is_expected.to be false }
    end

    context 'when legal aid application was not submitted for the original case' do
      before do
        allow(kase).to receive(:appeal_original_app_submitted).and_return('no')
      end

      it { is_expected.to be true }
    end

    context 'when legal aid application was submitted for the original case' do
      let(:appeal_original_app_submitted) { 'yes' }
      let(:appeal_reference) { [nil, nil] }

      before do
        allow(kase).to receive(:values_at).with(:appeal_maat_id, :appeal_usn).and_return(appeal_reference)
      end

      context 'when financial circumstances changed' do
        before do
          allow(kase).to receive(:appeal_financial_circumstances_changed).and_return('yes')
        end

        it 'returns true when details given' do
          allow(kase).to receive(:appeal_with_changes_details).and_return('Details about changes')
          expect(subject).to be true
        end

        it 'returns false when details not given' do
          allow(kase).to receive(:appeal_with_changes_details).and_return(nil)

          expect(subject).to be false
        end
      end

      context 'when financial circumstances have not changed' do
        before do
          allow(kase).to receive(:appeal_financial_circumstances_changed).and_return('no')
        end

        context 'and appeal reference given' do
          let(:appeal_reference) { [nil, '1231'] }

          it { is_expected.to be true }
        end

        context 'and appeal reference is not given' do
          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#validate' do
    subject(:validate) { validator.validate }

    context 'when not an appeal case' do
      it 'does not add errors' do
        expect(errors).not_to receive(:add)
        validate
      end
    end

    context 'when an appeal case' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it 'adds errors to :appeal_details when incomplete' do
        allow(validator).to receive(:complete?).and_return(false)
        expect(errors).to receive(:add).with(:appeal_details, :incomplete)

        validate
      end

      it 'does not add errors when complete' do
        allow(validator).to receive(:complete?).and_return(true)
        expect(errors).not_to receive(:add)

        validate
      end
    end
  end
end
