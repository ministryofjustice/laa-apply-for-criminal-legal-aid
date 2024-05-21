require 'rails_helper'

RSpec.describe Steps::Partner::NinoForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      has_nino:,
      nino:,
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner:
    )
  end

  let(:partner) { instance_double(Partner, has_nino:, nino:) }
  let(:has_nino) { nil }
  let(:nino) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_nino` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_nino, :inclusion)).to be(true)
      end
    end

    context 'when `has_nino` is invalid' do
      let(:has_nino) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_nino, :inclusion)).to be(true)
      end
    end

    context 'when `nino` is invalid' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'ABCDEFG' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
      end
    end

    context 'when `nino` is not provided' do
      let(:has_nino) { 'yes' }
      let(:nino) { '' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:nino, :blank)).to be(true)
      end
    end

    context 'when `has_nino` and `nino` is valid' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'JA293483A' }

      it 'saves the record' do
        expect(partner).to receive(:update).with(
          { 'has_nino' => YesNoAnswer::YES, 'nino' => 'JA293483A' }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `has_nino` is valid' do
      let(:has_nino) { 'no' }
      let(:nino) { 'NotRequired' }

      it 'saves the record' do
        expect(partner).to receive(:update).with(
          { 'has_nino' => YesNoAnswer::NO }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
