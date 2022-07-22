require 'rails_helper'

RSpec.describe Steps::Client::DetailsForm do
  let(:arguments) { {
    crime_application: crime_application,
    first_name: 'John',
    last_name: 'Doe',
    other_names: nil,
  } }

  let(:crime_application) { instance_double(CrimeApplication) }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'validations' do
      it { should validate_presence_of(:first_name) }
      it { should validate_presence_of(:last_name) }
      it { should_not validate_presence_of(:other_names) }
    end

    context 'when validations pass' do
      it_behaves_like 'a has-one-association form',
                      association_name: :applicant_detail,
                      expected_attributes: {
                        'first_name' => 'John',
                        'last_name' => 'Doe',
                        'other_names' => nil
                      }
    end
  end
end
