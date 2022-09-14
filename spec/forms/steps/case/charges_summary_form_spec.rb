require 'rails_helper'

RSpec.describe Steps::Case::ChargesSummaryForm do
  let(:arguments) { {
    crime_application: crime_application,
    add_offence: add_offence
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:add_offence) { nil }

  subject { described_class.new(arguments) }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `add_offence` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:add_offence, :inclusion)).to eq(true)
      end
    end

    context 'when `add_offence` is not valid' do
      let(:add_offence) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:add_offence, :inclusion)).to eq(true)
      end
    end

    context 'when there are no errors' do
      let(:add_offence) { 'yes' }

      it 'returns true' do
        expect(subject.save).to be(true)
      end
    end
  end
end
