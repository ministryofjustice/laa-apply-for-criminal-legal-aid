require 'rails_helper'

RSpec.describe Steps::Case::HearingDetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
    hearing_court_name: 'Cardiff Court',
    hearing_date: Date.tomorrow,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }

  describe '#save' do
    context 'validations' do
      it { is_expected.to validate_presence_of(:hearing_court_name) }
      it { is_expected.to validate_presence_of(:hearing_date) }
    end

    context 'hearing_date' do
      it_behaves_like 'a multiparam date validation',
                      attribute_name: :hearing_date,
                      allow_past: false, allow_future: true
    end

    context 'when validations pass' do
      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'hearing_court_name' => 'Cardiff Court',
                        'hearing_date' => Date.tomorrow,
                      }
    end
  end
end
