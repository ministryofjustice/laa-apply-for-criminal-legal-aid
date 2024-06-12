require 'rails_helper'

RSpec.describe Person, type: :model do
  subject(:person) { described_class.new(attributes) }

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
      allow(person).to receive(:home_address).and_return(mock_address)
    end

    context 'home address is not blank' do
      let(:address_line_one) { '1 North Pole' }

      it 'returns true when a home address has values' do
        expect(person.home_address?).to be(true)
      end
    end

    context 'home address is blank' do
      let(:address_line_one) { nil }

      it 'returns false when a home address does not have values' do
        expect(person.home_address?).to be(false)
      end
    end

    context 'there is no home address record' do
      let(:mock_address) { nil }

      it 'returns false' do
        expect(person.home_address?).to be(false)
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
      allow(person).to receive(:correspondence_address).and_return(mock_address)
    end

    context 'correspondence address is not blank' do
      let(:address_line_one) { '1 North Pole' }

      it 'returns true when a correspondence address has values' do
        expect(person.correspondence_address?).to be(true)
      end
    end

    context 'correspondence address is blank' do
      let(:address_line_one) { nil }

      it 'returns false when a correspondence address does not have values' do
        expect(person.correspondence_address?).to be(false)
      end
    end

    context 'there is no correspondence address record' do
      let(:mock_address) { nil }

      it 'returns false' do
        expect(person.correspondence_address?).to be(false)
      end
    end
  end

  describe '#over_18_at_date_stamp?' do
    subject(:over_18_at_date_stamp?) { person.over_18_at_date_stamp? }
    
    let(:eighteen_today_dob) { 18.years.ago.in_time_zone('London').to_date }
    let(:date_stamp) { nil }

    before do
      allow(person).to receive(:crime_application).and_return(
        instance_double(CrimeApplication, date_stamp: )
      )

      person.date_of_birth = date_of_birth
    end

    context 'when date_stamp is not set' do
      context 'when person 18 tomorrow' do
        let(:date_of_birth) { eighteen_today_dob.next_day }

        it { is_expected.to be false }
      end

      context 'when person 18 today' do
        let(:date_of_birth) { eighteen_today_dob }

        it { is_expected.to be true }
      end

      context 'when person 18 yesterday' do
        let(:date_of_birth) { eighteen_today_dob.prev_day }

        it { is_expected.to be true }
      end
    end

    context 'when date_stamp was yesterday' do
      let(:date_stamp) { 1.day.ago }

      context 'when person 18 tomorrow' do
        let(:date_of_birth) { eighteen_today_dob.next_day }

        it { is_expected.to be false }
      end

      context 'when person 18 today' do
        let(:date_of_birth) { eighteen_today_dob }

        it { is_expected.to be false }
      end

      context 'when person 18 yeterday' do
        let(:date_of_birth) { eighteen_today_dob.prev_day }

        it { is_expected.to be true }
      end
    end
  end
end
