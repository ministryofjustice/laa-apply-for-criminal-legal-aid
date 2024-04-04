require 'rails_helper'

RSpec.describe Codefendant, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      first_name: 'Joe',
      last_name: 'Test',
      conflict_of_interest: YesNoAnswer::YES
    }
  end

  describe '#complete?' do
    context 'with valid attributes' do
      it 'returns true' do
        expect(subject.complete?).to be(true)
      end
    end

    context 'with invalid attributes' do
      before { attributes.merge!(first_name: nil) }

      it 'returns false' do
        expect(subject.complete?).to be(false)
      end
    end
  end
end
