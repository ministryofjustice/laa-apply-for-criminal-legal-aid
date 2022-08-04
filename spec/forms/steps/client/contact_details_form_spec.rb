require 'rails_helper'

RSpec.describe Steps::Client::ContactDetailsForm do
  let(:arguments) { {
    crime_application: crime_application
  } }

  let(:crime_application) { instance_double(CrimeApplication) }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'when validations pass' do
      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {}
    end
  end
end
