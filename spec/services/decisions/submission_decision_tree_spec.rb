require 'rails_helper'

RSpec.describe Decisions::SubmissionDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:applicant) { instance_double(Applicant) }
  let(:kase) { instance_double(Case) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      applicant: applicant,
      case: kase,
      partner_detail: nil,
      partner: nil
    )
  end

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `more_information`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :more_information }

    context 'has correct next step' do
      it { is_expected.to have_destination(:review, :edit, id: crime_application) }
    end
  end

  context 'when the step is `review`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :review }
    let(:benefit_type) { nil }
    let(:is_client_remanded) { YesNoAnswer::YES.to_s }
    let(:not_means_tested) { nil }
    let(:appeal_no_changes?) { false }
    let(:case_type) { CaseType::SUMMARY_ONLY }

    before do
      allow(applicant).to receive_messages(has_nino:, benefit_type:)
      allow(kase).to receive_messages(is_client_remanded:, case_type:)
      allow(crime_application).to receive_messages(
        not_means_tested?: not_means_tested,
        appeal_no_changes?: appeal_no_changes?
      )
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'when nino not provided' do
      let(:has_nino) { YesNoAnswer::NO.to_s }

      context 'but is forthcoming' do
        let(:not_means_tested) { false }

        before do
          allow(subject).to receive(:nino_forthcoming?).and_return(true)
        end

        context 'when in custody' do
          let(:is_client_remanded) { YesNoAnswer::YES.to_s }

          it { is_expected.to have_destination(:declaration, :edit, id: crime_application) }
        end

        context 'when not in custody' do
          let(:is_client_remanded) { YesNoAnswer::NO.to_s }

          it { is_expected.to have_destination(:cannot_submit_without_nino, :edit, id: crime_application) }
        end
      end

      context 'and is not required to submit for an appeal no changes' do
        let(:appeal_no_changes?) { true }

        it { is_expected.to have_destination(:declaration, :edit, id: crime_application) }
      end

      context 'and is not required to submit for a non-means tested application' do
        let(:not_means_tested) { true }

        it { is_expected.to have_destination(:declaration, :edit, id: crime_application) }
      end
    end

    context 'when nino is provided' do
      let(:has_nino) { YesNoAnswer::YES.to_s }

      it { is_expected.to have_destination(:declaration, :edit, id: crime_application) }
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end

  context 'when the step is `declaration`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :declaration }

    let(:submission_success) { true }

    before do
      # We don't test its implementation as this is tested separately
      allow_any_instance_of(Datastore::ApplicationSubmission).to receive(:call).and_return(submission_success)
    end

    context 'submits the application' do
      it 'calls the submission service' do
        expect(
          Datastore::ApplicationSubmission
        ).to receive(:new).with(crime_application).and_call_original

        subject.destination
      end
    end

    context 'has correct next step' do
      context 'when the submission was successful' do
        let(:submission_success) { true }

        it { is_expected.to have_destination(:confirmation, :show, id: crime_application) }
      end

      context 'when the submission was unsuccessful' do
        let(:submission_success) { false }

        it { is_expected.to have_destination(:failure, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `submission_retry`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :submission_retry }

    it 'retries the submission of the application' do
      expect(subject).to receive(:submit_application)
      subject.destination
    end
  end

  context 'when the step is `after_cannot_submit_without_nino`' do
    let(:form_object) { double('FormObject', applicant:, will_enter_nino:) }
    let(:step_name) { :cannot_submit_without_nino }

    context 'and the answer is `yes`' do
      let(:will_enter_nino) { YesNoAnswer::YES }

      it { is_expected.to have_destination('/steps/client/has_nino', :edit, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:will_enter_nino) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:review, :edit, id: crime_application) }
    end
  end
end
