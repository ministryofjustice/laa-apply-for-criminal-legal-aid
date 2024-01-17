require 'rails_helper'

RSpec.describe TypeOfApplication do
  let(:crime_application_class) do
    Struct.new(:reviewed_at, :returned_at, :application_type) do
      include TypeOfApplication
    end
  end

  let(:crime_application) do
    crime_application_class.new(reviewed_at, returned_at, application_type)
  end

  let(:reviewed_at) { 1.day.ago }
  let(:returned_at) { nil }
  let(:application_type) { 'initial' }

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
end
