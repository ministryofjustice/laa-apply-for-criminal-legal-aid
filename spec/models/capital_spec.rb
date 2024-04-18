require 'rails_helper'

RSpec.describe Capital, type: :model do
  subject(:instance) { described_class.new(attributes) }

  let(:attributes) do
    { crime_application: CrimeApplication.new, has_no_other_assets: has_no_other_assets }
  end

  let(:has_no_other_assets) { nil }

  describe '#confirmed?' do
    subject(:confirmed?) { instance.confirmation_validator.confirmed? }

    context 'when has_no_other_assets nil' do
      it { is_expected.to be false }
    end

    context 'when has_no_other_assets no' do
      let(:has_no_other_assets) { 'onotherstring' }

      it { is_expected.to be false }
    end

    context 'when has_no_other_assets true' do
      let(:has_no_other_assets) { 'yes' }

      it { is_expected.to be true }
    end
  end

  describe '#complete?' do
    subject(:complete?) { instance.complete? }

    context 'when #confirmed?' do
      let(:has_no_other_assets) { 'yes' }

      it { is_expected.to be true }

      context 'when has incomplete answers' do
        before { instance.national_savings_certificates.build }

        it { is_expected.to be false }
      end
    end
  end

  describe '#all_answers_complete?' do
    subject(:all_answers_complete?) { instance.answers_validator.all_complete? }

    context 'when empty records' do
      it { is_expected.to be true }
    end

    context 'with in incomplete property' do
      before { instance.properties.build }

      it { is_expected.to be false }
    end

    context 'with an incomplete saving' do
      before { instance.savings.build }

      it { is_expected.to be false }
    end

    context 'with an incomplete investment' do
      before { instance.investments.build }

      it { is_expected.to be false }
    end

    context 'with an incomplete national_savings_certificates' do
      before { instance.national_savings_certificates.build }

      it { is_expected.to be false }
    end

    context 'with a complete national_savings_certificates' do
      before do
        allow(instance).to receive(:national_savings_certificates) {
          [double(NationalSavingsCertificate, complete?: true)]
        }
      end

      it { is_expected.to be true }
    end
  end

  describe 'valid?(:check_answers)' do
    subject(:valid?) { instance.valid?(:check_answers) }

    context 'when not confirmed' do
      it { is_expected.to be true }
    end

    context 'when some answers are incomplete' do
      before { instance.properties.build }

      it { is_expected.to be false }
    end
  end

  describe 'valid?(:submission)' do
    subject(:valid?) { instance.valid?(:submission) }

    context 'when not confirmed' do
      it { is_expected.to be false }
    end

    context 'when confirmed' do
      let(:has_no_other_assets) { 'yes' }

      context 'and without incomplete answers' do
        it { is_expected.to be true }
      end

      context 'when some answers are incomplete' do
        before { instance.properties.build }

        it { is_expected.to be false }
      end
    end
  end
end
