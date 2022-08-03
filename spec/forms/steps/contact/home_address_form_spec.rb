require 'rails_helper'

RSpec.describe Steps::Contact::HomeAddressForm do
  let(:arguments) { {
    crime_application: crime_application,
    home_address_line_one: 'Address line 1',
    home_address_line_two: 'Address line 2',
    home_city: 'City',
    home_county: 'County',
    home_postcode: 'Postcode',
  } }

  let(:crime_application) { instance_double(CrimeApplication) }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'validations' do
      it { should validate_presence_of(:home_address_line_one) }
      it { should validate_presence_of(:home_city) }
      it { should validate_presence_of(:home_postcode) }

      it { should_not validate_presence_of(:home_address_line_two) }
      it { should_not validate_presence_of(:home_county) }
    end

    context 'when validations pass' do
      it_behaves_like 'a has-one-association form',
                      association_name: :applicant_contact_details,
                      expected_attributes: {
                        'home_address_line_one' => 'Address line 1',
                        'home_address_line_two' => 'Address line 2',
                        'home_city' => 'City',
                        'home_county' => 'County',
                        'home_postcode' => 'Postcode'
                      }
    end
  end
end
