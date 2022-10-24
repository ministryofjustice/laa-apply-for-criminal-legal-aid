require 'rails_helper'

RSpec.describe Decisions::SubmissionDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `review`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :review }

    context 'has correct next step' do
      it { is_expected.to have_destination(:declaration, :edit, id: crime_application) }
    end
  end

  context 'when the step is `declaration`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :declaration }

    context 'has correct next step' do
      it { is_expected.to have_destination(:confirmation, :show, id: crime_application) }
    end
  end
end
