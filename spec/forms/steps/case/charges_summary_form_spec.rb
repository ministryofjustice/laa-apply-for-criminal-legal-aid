require 'rails_helper'

RSpec.describe Steps::Case::ChargesSummaryForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      add_offence:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:add_offence) { nil }

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
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:add_offence, :inclusion)).to be(true)
      end
    end

    context 'when `add_offence` is not valid' do
      let(:add_offence) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:add_offence, :inclusion)).to be(true)
      end
    end

    context 'when there are charges with missing details' do
      let(:charges_collection) do
        [
          instance_double(Charge, complete?: true),
          instance_double(Charge, complete?: false),
        ]
      end

      before do
        allow(subject).to receive(:charges).and_return(charges_collection)
      end

      context 'and `add_offence` is `yes`' do
        let(:add_offence) { 'yes' }

        it 'does not validate existing charges' do
          expect(subject).not_to receive(:all_charges_have_details)
          subject.save
        end

        it 'returns true' do
          expect(subject.save).to be(true)
        end
      end

      context 'and `add_offence` is `no`' do
        let(:add_offence) { 'no' }

        it 'has a validation error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:base, :missing_details)).to be(true)
        end

        it 'returns false' do
          expect(subject.save).to be(false)
        end
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
