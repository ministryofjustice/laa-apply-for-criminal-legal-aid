require 'rails_helper'

RSpec.describe Decisions::CircumstancesDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      pre_cifc_reference_number:,
      pre_cifc_maat_id:,
      pre_cifc_usn:,
      pre_cifc_reason:,
    )
  end

  let(:pre_cifc_reference_number) { nil }
  let(:pre_cifc_maat_id) { nil }
  let(:pre_cifc_usn) { nil }
  let(:pre_cifc_reason) { nil }

  it_behaves_like 'a decision tree'

  context 'when the step is `pre_cifc_reference_number`' do
    let(:form_object) do
      double(
        'FormObject',
        current_crime_application: crime_application,
        crime_application: crime_application,
        pre_cifc_reference_number: 'pre_cifc_usn',
        pre_cifc_usn: 'USNABCD',
      )
    end

    let(:step_name) { :pre_cifc_reference_number }

    it { is_expected.to have_destination(:pre_cifc_reason, :edit, id: crime_application) }
  end

  context 'when the step is `pre_cifc_reason`' do
    let(:form_object) do
      double(
        'FormObject',
        current_crime_application: crime_application,
        crime_application: crime_application,
        pre_cifc_reason: 'Won the lottery',
      )
    end

    let(:step_name) { :pre_cifc_reason }

    it { is_expected.to have_destination('/steps/client/details', :edit, id: crime_application) }
  end
end
