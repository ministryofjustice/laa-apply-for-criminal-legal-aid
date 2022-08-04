require 'rails_helper'

RSpec.describe Steps::Address::DetailsForm do
  let(:arguments) { {
    crime_application: crime_application,
    record: address_record,
    address_line_one: 'Address line 1',
    address_line_two: 'Address line 2',
    city: 'City',
    county: 'County',
    postcode: 'Postcode',
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:address_record) { instance_double(Address) }

  subject { described_class.new(arguments) }

  describe 'validations' do
    it { should validate_presence_of(:address_line_one) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:postcode) }

    it { should_not validate_presence_of(:address_line_two) }
    it { should_not validate_presence_of(:county) }
  end

  describe '#save' do
    context 'for valid details' do
      it 'updates the record' do
        expect(address_record).to receive(:update).with(
          'address_line_one' => 'Address line 1',
          'address_line_two' => 'Address line 2',
          'city' => 'City',
          'county' => 'County',
          'postcode' => 'Postcode',
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
