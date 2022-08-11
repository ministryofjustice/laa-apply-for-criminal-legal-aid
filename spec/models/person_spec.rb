require 'rails_helper'

RSpec.describe Person, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) { {} }

  let(:mock_home_address) { 
    instance_double(
      'Address', 
      address_line_one: address_line_one
    )
  }


  before do
    allow(subject).to receive(:home_address).and_return(mock_home_address)
  end

  describe '#has_home_address?' do
    context 'home address is not blank' do

      let(:address_line_one) { '1 North Pole' }

      it 'returns true when a home address has values' do
        expect(subject.home_address?).to be(true)
      end
    end

    context 'home address has is blank' do

      let(:address_line_one) { nil }

      it 'returns false when a home address does not have values' do
        expect(subject.home_address?).to be(false)
      end
    end
  end
end
