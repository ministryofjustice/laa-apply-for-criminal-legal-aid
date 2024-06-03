require 'rails_helper'

RSpec.describe Steps::Client::RelationshipStatusForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      relationship_status:,
      separation_date:,
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner_detail:
    )
  end

  let(:partner_detail) do
    instance_double(PartnerDetail, relationship_status:, separation_date:)
  end

  let(:relationship_status) { nil }
  let(:separation_date) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices.map(&:to_s)
      ).to match_array(%w[single widowed divorced separated prefer_not_to_say])
    end
  end

  describe 'separation_date' do
    let(:relationship_status) { 'separated' }
    let(:separation_date) { 2.years.ago.to_date }

    it_behaves_like 'a multiparam date validation', attribute_name: :separation_date
  end

  describe '#save' do
    context 'when `relationship_status` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:relationship_status, :inclusion)).to be(true)
      end
    end

    context 'when `relationship_status` is invalid' do
      let(:relationship_status) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:relationship_status, :inclusion)).to be(true)
      end
    end

    context 'when `relationship_status` is valid' do
      let(:relationship_status) { 'divorced' }

      it 'saves the record' do
        expect(partner_detail).to receive(:update).with(
          {
            'relationship_status' => ClientRelationshipStatusType::DIVORCED,
            'separation_date' => nil,
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `relationship_status` is separated and separation date provided' do
      let(:relationship_status) { 'separated' }
      let(:separation_date) { 2.years.ago.to_date }

      it 'saves the record' do
        expect(partner_detail).to receive(:update).with(
          {
            'relationship_status' => ClientRelationshipStatusType::SEPARATED,
            'separation_date' => 2.years.ago.to_date,
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `relationship_status` is separated and separation date is not provided' do
      let(:relationship_status) { 'separated' }
      let(:separation_date) { '' }

      it 'does not save the record' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:separation_date, :blank)).to be(true)
        expect(subject.save).to be(false)
      end
    end
  end
end
