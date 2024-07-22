require 'rails_helper'

RSpec.describe Steps::Client::IsMeansTestedForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      is_means_tested:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, is_means_tested:) }
  let(:is_means_tested) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#is_means_tested' do
    it 'is yes by default' do
      expect(form.is_means_tested).to eq YesNoAnswer::YES
    end
  end

  describe '#save' do
    context 'when `is_means_tested` is not provided', skip: 'CRIMAPP-1249 temporary behaviour change' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:is_means_tested, :inclusion)).to be(true)
      end
    end

    context 'when `is_means_tested` is not valid' do
      let(:is_means_tested) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:is_means_tested, :inclusion)).to be(true)
      end
    end

    context 'when `is_means_tested` is valid' do
      let(:is_means_tested) { 'no' }

      it 'saves the record' do
        expect(crime_application).to receive(:update).with(
          { 'is_means_tested' => YesNoAnswer::NO }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
