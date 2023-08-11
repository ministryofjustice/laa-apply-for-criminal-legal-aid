require 'rails_helper'

RSpec.describe Decisions::EvidenceDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
    )
  end

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `upload`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :upload }

    context 'has correct next step' do
      it { is_expected.to have_destination('/steps/submission/review', :edit, id: crime_application) }
    end
  end
end
