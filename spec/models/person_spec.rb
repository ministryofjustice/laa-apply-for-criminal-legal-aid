require 'rails_helper'

RSpec.describe Person, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      first_name: 'Joe',
      last_name: 'Bloggs',
    }
  end

  let(:address_line_one) { '1 North Pole' }

  describe '#home_address?' do
    let(:mock_address) do
      instance_double(
        HomeAddress,
        address_line_one:
      )
    end

    before do
      allow(subject).to receive(:home_address).and_return(mock_address)
    end

    context 'home address is not blank' do
      let(:address_line_one) { '1 North Pole' }

      it 'returns true when a home address has values' do
        expect(subject.home_address?).to be(true)
      end
    end

    context 'home address is blank' do
      let(:address_line_one) { nil }

      it 'returns false when a home address does not have values' do
        expect(subject.home_address?).to be(false)
      end
    end

    context 'there is no home address record' do
      let(:mock_address) { nil }

      it 'returns false' do
        expect(subject.home_address?).to be(false)
      end
    end
  end

  describe '#correspondence_address?' do
    let(:mock_address) do
      instance_double(
        CorrespondenceAddress,
        address_line_one:
      )
    end

    before do
      allow(subject).to receive(:correspondence_address).and_return(mock_address)
    end

    context 'correspondence address is not blank' do
      let(:address_line_one) { '1 North Pole' }

      it 'returns true when a correspondence address has values' do
        expect(subject.correspondence_address?).to be(true)
      end
    end

    context 'correspondence address is blank' do
      let(:address_line_one) { nil }

      it 'returns false when a correspondence address does not have values' do
        expect(subject.correspondence_address?).to be(false)
      end
    end

    context 'there is no correspondence address record' do
      let(:mock_address) { nil }

      it 'returns false' do
        expect(subject.correspondence_address?).to be(false)
      end
    end
  end
end
