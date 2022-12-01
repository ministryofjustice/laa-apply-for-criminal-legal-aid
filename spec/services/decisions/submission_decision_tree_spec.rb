require 'rails_helper'

RSpec.describe Decisions::SubmissionDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication, id: 'uuid', usn: 123,
    )
  end

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

    let(:submission_success) { true }

    before do
      # We don't test its implementation as this is tested separately
      allow_any_instance_of(ApplicationSubmission).to receive(:call).and_return(submission_success)
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
      context 'when the submission was successful' do
        let(:submission_success) { true }

        it { is_expected.to have_destination(:confirmation, :show, id: crime_application, reference: 123) }
      end

      context 'when the submission was unsuccessful' do
        let(:submission_success) { false }

        it { is_expected.to have_destination('/errors', :unhandled, id: nil) }
      end
    end
  end
end
