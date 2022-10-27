require 'rails_helper'

RSpec.describe Decisions::SubmissionDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, id: '123456789') }

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

    before do
      # We don't test its implementation as this is tested separately
      allow_any_instance_of(ApplicationSubmission).to receive(:call).and_return(true)
    end

    context 'submits the application' do
      it 'calls the submission service' do
        expect(
          ApplicationSubmission
        ).to receive(:new).with(crime_application).and_call_original

        subject.destination
      end
    end

    context 'has correct next step' do
      it { is_expected.to have_destination(:confirmation, :show, id: crime_application, reference: 'LAA-123456') }
    end
  end
end
