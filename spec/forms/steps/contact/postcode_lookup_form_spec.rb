require 'rails_helper'

RSpec.describe Steps::Contact::PostcodeLookupForm do
  let(:arguments) { {
    crime_application: crime_application,
    home_postcode: 'Postcode',
  } }

  let(:crime_application) { instance_double(CrimeApplication) }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'validations' do
      it { should validate_presence_of(:home_postcode) }
    end

    context 'when validations pass' do
      it_behaves_like 'a has-one-association form',
                      association_name: :applicant_contact_details,
                      expected_attributes: {
                        'home_postcode' => 'Postcode'
                      }
    end
  end
end
