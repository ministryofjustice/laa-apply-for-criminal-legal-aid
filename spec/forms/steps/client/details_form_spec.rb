require 'rails_helper'

RSpec.describe Steps::Client::DetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
    first_name: 'John',
    last_name: 'Doe',
    other_names: nil,
    date_of_birth: Date.yesterday,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }

  describe '#save' do
    context 'validations' do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_presence_of(:date_of_birth) }
      it { is_expected.not_to validate_presence_of(:other_names) }
    end

    context 'date_of_birth' do
      it_behaves_like 'a multiparam date validation',
                      attribute_name: :date_of_birth
    end

    context 'when validations pass' do
      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'first_name' => 'John',
                        'last_name' => 'Doe',
                        'other_names' => nil,
                        'date_of_birth' => Date.yesterday,
                      }
    end
  end
end
