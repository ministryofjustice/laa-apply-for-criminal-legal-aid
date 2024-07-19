require 'rails_helper'

RSpec.describe Circumstances::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record:, crime_application:) }

  let(:record) { crime_application }

  let(:crime_application) do
    CrimeApplication.new(
      application_type:,
      pre_cifc_reference_number:,
      pre_cifc_maat_id:,
      pre_cifc_usn:,
    )
  end

  let(:application_type) { 'change_in_financial_circumstances' }
  let(:pre_cifc_reference_number) { nil }
  let(:pre_cifc_maat_id) { nil }
  let(:pre_cifc_usn) { nil }

  before do
    allow(FeatureFlags).to receive(:cifc_journey) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when application is change in financial circumstances' do
      let(:application_type) { 'change_in_financial_circumstances' }

      it { is_expected.to be true }
    end

    context 'application is not change in financial circumstances' do
      let(:application_type) { 'initial' }

      it { is_expected.to be false }
    end
  end

  describe '#complete?' do
    subject(:complete?) do
      described_class.new(record:, crime_application:)
    end

    context 'with empty cifc fields' do
      it 'is false' do
        expect(subject.complete?).to be false
        expect(subject.errors.of_kind?('pre_cifc_reference_number', :blank)).to be(true)
      end
    end

    context 'with pre_cifc_reference_number set without a MAAT ID' do
      let(:pre_cifc_reference_number) { 'pre_cifc_maat_id' }
      let(:pre_cifc_maat_id) { nil }

      it 'is false' do
        expect(subject.complete?).to be false
        expect(subject.errors.of_kind?('pre_cifc_maat_id', :blank)).to be(true)
      end
    end

    context 'with pre_cifc_reference_number set with a MAAT ID' do
      let(:pre_cifc_reference_number) { 'pre_cifc_maat_id' }
      let(:pre_cifc_maat_id) { '1234567' }

      it { expect(subject.complete?).to be true }
    end

    context 'with pre_cifc_reference_number set without a USN' do
      let(:pre_cifc_reference_number) { 'pre_cifc_usn' }
      let(:pre_cifc_usn) { nil }

      it 'is false' do
        expect(subject.complete?).to be false
        expect(subject.errors.of_kind?('pre_cifc_usn', :blank)).to be(true)
      end
    end

    context 'with pre_cifc_reference_number set with a USN' do
      let(:pre_cifc_reference_number) { 'pre_cifc_usn' }
      let(:pre_cifc_usn) { 'USN78171' }

      it { expect(subject.complete?).to be true }
    end
  end

  describe '#circumstances_complete?' do
    context 'when not complete' do
      it 'is false' do
        expect(subject.circumstances_complete?).to be false
        expect(subject.errors).to be_empty
      end
    end

    context 'when complete' do
      let(:pre_cifc_reference_number) { 'pre_cifc_maat_id' }
      let(:pre_cifc_maat_id) { '1234567' }

      it 'is true' do
        expect(subject.circumstances_complete?).to be true
        expect(subject.errors).to be_empty
      end
    end
  end
end
