require 'rails_helper'

RSpec.describe Steps::Case::FirstCourtHearingForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      first_court_hearing_name: 'Cardiff Court',
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }

  describe '#save' do
    context 'validations' do
      it { is_expected.to validate_presence_of(:first_court_hearing_name) }
    end

    context 'when validations pass' do
      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'first_court_hearing_name' => 'Cardiff Court',
                      }
    end
  end
end
