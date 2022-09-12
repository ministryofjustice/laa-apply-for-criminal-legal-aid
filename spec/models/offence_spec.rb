require 'rails_helper'

RSpec.describe Offence, type: :model do
  subject { described_class.new(attributes) }
  let(:attributes) { {} }

  describe '#code' do
    let(:attributes) { { id: 'ABC123'} }

    it 'is an alias of the `id` attribute' do
      expect(subject.code).to eq('ABC123')
    end
  end
end
