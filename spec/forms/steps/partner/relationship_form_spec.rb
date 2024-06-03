require 'rails_helper'

RSpec.describe Steps::Partner::RelationshipForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      relationship_to_partner:
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner_detail:
    )
  end

  let(:partner_detail) { instance_double(PartnerDetail) }
  let(:relationship_to_partner) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices.map(&:to_s)
      ).to match_array(%w[married_or_partnership living_together prefer_not_to_say])
    end
  end

  describe '#save' do
    context 'when `relationship_to_partner` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:relationship_to_partner, :inclusion)).to be(true)
      end
    end

    context 'when `relationship_to_partner` is invalid' do
      let(:relationship_to_partner) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:relationship_to_partner, :inclusion)).to be(true)
      end
    end

    context 'when `relationship_to_partner` is valid' do
      let(:relationship_to_partner) { 'prefer_not_to_say' }

      it 'saves the record' do
        expect(partner_detail).to receive(:update).with(
          { 'relationship_to_partner' => RelationshipToPartnerType::NOT_SAYING }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
