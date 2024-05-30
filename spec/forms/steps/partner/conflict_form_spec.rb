require 'rails_helper'

RSpec.describe Steps::Partner::ConflictForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      conflict_of_interest:
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner_detail:
    )
  end

  let(:partner_detail) { instance_double(PartnerDetail) }
  let(:conflict_of_interest) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `conflict_of_interest` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:conflict_of_interest, :inclusion)).to be(true)
      end
    end

    context 'when `conflict_of_interest` is invalid' do
      let(:conflict_of_interest) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:conflict_of_interest, :inclusion)).to be(true)
      end
    end

    context 'when `conflict_of_interest` is valid' do
      let(:conflict_of_interest) { 'yes' }

      it 'saves the record' do
        expect(partner_detail).to receive(:update).with(
          { 'conflict_of_interest' => YesNoAnswer::YES }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
