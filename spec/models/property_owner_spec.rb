require 'rails_helper'

RSpec.describe PropertyOwner, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      name: 'Joe',
      relationship: RelationshipType::FRIENDS.to_s,
      percentage_owned: 10,
      property_id: double(Property, id: 1).id
    }
  end

  describe '#complete?' do
    context 'with valid attributes' do
      it 'returns true' do
        expect(subject.complete?).to be(true)
      end
    end

    context 'with invalid attributes' do
      before { attributes.merge!(name: nil) }

      it 'returns false' do
        expect(subject.complete?).to be(false)
      end
    end
  end
end
