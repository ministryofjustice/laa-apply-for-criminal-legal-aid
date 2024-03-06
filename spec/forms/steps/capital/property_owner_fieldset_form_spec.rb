require 'rails_helper'

RSpec.describe Steps::Capital::PropertyOwnerFieldsetForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      id: record_id,
      name: 'John',
      relationship: 'friends',
      percentage_owned: 10,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record_id) { '12345' }

  describe '#relationships' do
    it 'returns the possible choices' do
      expect(subject.relationships).to eq(
        [
          RelationshipType::BUSINESS_ASSOCIATES,
          RelationshipType::EX_PARTNER,
          RelationshipType::FAMILY_MEMBERS,
          RelationshipType::FRIENDS,
          RelationshipType::HOUSE_BUILDER,
          RelationshipType::HOUSING_ASSOCIATION,
          RelationshipType::LOCAL_AUTHORITY,
          RelationshipType::PARTNER_WITH_A_CONTRARY_INTEREST,
          RelationshipType::PROPERTY_COMPANY,
        ]
      )
    end
  end

  describe '#persisted?' do
    context 'when the record has an ID' do
      it { expect(subject.persisted?).to be(true) }
    end

    context 'when the record has no ID' do
      let(:record_id) { nil }

      it { expect(subject.persisted?).to be(false) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:relationship) }
    it { is_expected.to validate_presence_of(:percentage_owned) }

    context 'validate custom_relationship' do
      before { allow(subject).to receive(:custom_relationship?).and_return(custom_relationship_selected) }

      context 'when custom_relationship is selected' do
        let(:custom_relationship_selected) { true }

        it { is_expected.to validate_presence_of(:custom_relationship) }
      end

      context 'when custom_relationship is not selected' do
        let(:custom_relationship_selected) { false }

        it { is_expected.not_to validate_presence_of(:custom_relationship) }
      end
    end
  end
end
