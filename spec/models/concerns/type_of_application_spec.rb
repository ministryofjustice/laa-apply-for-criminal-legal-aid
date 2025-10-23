require 'rails_helper'

RSpec.describe TypeOfApplication do
  let(:crime_application_class) do
    Struct.new(:reviewed_at, :returned_at, :application_type, :kase) do
      include TypeOfApplication
    end
  end

  let(:crime_application) do
    crime_application_class.new(reviewed_at, returned_at, application_type, kase)
  end

  let(:reviewed_at) { 1.day.ago }
  let(:returned_at) { nil }
  let(:application_type) { 'initial' }
  let(:kase) { nil }

  describe '#reviewed?' do
    subject(:reviewed) { crime_application.reviewed? }

    context 'when the application has been reviewed' do
      it { is_expected.to be true }
    end

    context 'when the application has not been reviewed' do
      let(:reviewed_at) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#returned?' do
    subject(:returned) { crime_application.returned? }

    context 'when the application has been returned' do
      let(:returned_at) { 1.day.ago }

      it { is_expected.to be true }
    end

    context 'when the application has not been returned' do
      it { is_expected.to be false }
    end
  end

  describe '#intial?' do
    subject(:initial) { crime_application.initial? }

    context 'when application type is "initial"' do
      it { is_expected.to be true }
    end

    context 'when application type is "post_submission_evidence"' do
      let(:application_type) { 'post_submission_evidence' }

      it { is_expected.to be false }
    end
  end

  describe '#can_receive_pse?' do
    subject(:can_receive_pse) { crime_application.can_receive_pse? }

    context 'when an initial, reviewed application' do
      it { is_expected.to be true }
    end

    context 'when not an initial application' do
      let(:application_type) { 'post_submission_evidence' }

      it { is_expected.to be false }
    end

    context 'when a returned application' do
      let(:returned_at) { 1.day.ago }

      it { is_expected.to be false }
    end
  end

  describe '#appeal_no_changes?' do
    subject(:appeal_no_changes?) { crime_application.appeal_no_changes? }

    let(:appeal_original_app_submitted) { 'yes' }
    let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }
    let(:appeal_financial_circumstances_changed) { 'no' }

    before do
      allow(crime_application).to receive(:kase).and_return(
        instance_double(
          Case, appeal_original_app_submitted:, case_type:, appeal_financial_circumstances_changed:
        )
      )
    end

    context 'with no financial changes since the original application' do
      it { is_expected.to be true }
    end

    context 'when no original application' do
      let(:appeal_original_app_submitted) { 'no' }

      it { is_expected.to be false }
    end

    context 'when not an appeal' do
      let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

      it { is_expected.to be false }
    end

    context 'with financial changes' do
      let(:appeal_financial_circumstances_changed) { 'yes' }

      it { is_expected.to be false }
    end

    context 'when kase is nil' do
      before do
        allow(crime_application).to receive(:kase)
      end

      it { is_expected.to be false }
    end
  end
end
