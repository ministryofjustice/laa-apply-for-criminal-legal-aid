require 'rails_helper'

RSpec.describe AppealDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) do
    instance_double(
      CrimeApplication,
      errors: errors,
      kase: kase,
      non_means_tested?: false,
      cifc?: cifc?,
    )
  end

  let(:errors) { double(:errors, empty?: false) }
  let(:kase) { Case.new(case_type:) }
  let(:case_type) { nil }
  let(:cifc?) { false }

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

    let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

    context 'when appeal_lodged_date is missing' do
      before do
        kase.appeal_lodged_date = nil
        kase.appeal_original_app_submitted = 'no'
      end

      it { is_expected.to be false }
    end

    context 'when appeal original app submitted not answered' do
      before do
        kase.appeal_original_app_submitted = nil
        kase.appeal_lodged_date = '2023-11-11'
      end

      it { is_expected.to be false }
    end

    context 'when appeal lodged date and app submitted answered' do
      before do
        kase.appeal_original_app_submitted = 'no'
        kase.appeal_lodged_date = '2023-11-11'
      end

      it { is_expected.to be true }
    end

    context 'when legal aid app was submitted for the original case' do
      before do
        kase.appeal_lodged_date = '2023-11-11'
        kase.appeal_original_app_submitted = 'yes'
      end

      context 'when financial circumstances changed' do
        before do
          kase.appeal_financial_circumstances_changed = 'yes'
        end

        it 'returns true when details given' do
          kase.appeal_with_changes_details = 'Details about changes'

          expect(subject).to be true
        end

        it 'returns false when details are not given' do
          expect(subject).to be false
        end
      end

      context 'when financial circumstances have not changed' do
        before do
          kase.appeal_financial_circumstances_changed = 'no'
        end

        context 'and an appeal reference is not given' do
          it { is_expected.to be false }
        end

        context 'and an appeal MAAT ID is given' do
          before do
            kase.appeal_maat_id = '123456'
          end

          it { is_expected.to be true }
        end

        context 'and an appeal USN is given' do
          before do
            kase.appeal_usn = 123_456
          end

          it { is_expected.to be true }
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

    context 'when valid change in financial circumstances application' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }
      let(:cifc?) { true }
      let(:appeal_lodged_date) { '2023-11-11' }
      let(:appeal_original_app_submitted) { 'yes' }

      before do
        allow(kase).to receive_messages(
          appeal_lodged_date:,
          appeal_original_app_submitted:
        )
      end

      it 'does not add errors when complete' do
        expect(errors).not_to receive(:add)

        validate
      end
    end

    context 'when invalid change in financial circumstances application' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }
      let(:cifc?) { true }
      let(:appeal_lodged_date) { nil }
      let(:appeal_original_app_submitted) { nil }

      before do
        allow(kase).to receive_messages(
          appeal_lodged_date:,
          appeal_original_app_submitted:
        )
      end

      it 'does not add errors when complete' do
        expect(errors).to receive(:add)

        validate
      end
    end
  end
end
