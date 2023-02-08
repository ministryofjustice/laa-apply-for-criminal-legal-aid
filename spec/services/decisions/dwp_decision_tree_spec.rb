require 'rails_helper'

RSpec.describe Decisions::DWPDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:applicant) { instance_double(Applicant, passporting_benefit:) }
  let(:passporting_benefit) { false }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)

    allow(
      form_object
    ).to receive(:applicant).and_return(applicant)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is retry_benefit_check' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :retry_benefit_check }

    before do
      allow(crime_application).to receive(:applicant).and_return(applicant)
      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(applicant).and_return(true)
      allow(applicant).to receive(:passporting_benefit?).and_return(passporting_benefit)
      allow(applicant).to receive(:passporting_benefit).and_return(passporting_benefit)
    end

    context 'when the applicant has a passporting benefit' do
      context 'has correct next step' do
        let(:passporting_benefit) { true }

        it { is_expected.to have_destination('steps/client/benefit_check_result', :edit, id: crime_application) }
      end
    end

    context 'when the applicant does not have a passporting benefit' do
      context 'has correct next step' do
        it { is_expected.to have_destination(:confirm_result, :edit, id: crime_application) }
      end
    end

    context 'when the benefit checker cannot check on the status of the passporting benefit' do
      context 'has correct next step' do
        let(:passporting_benefit) { nil }

        it { is_expected.to have_destination(:retry_benefit_check, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `confirm_result`' do
    let(:form_object) { double('FormObject', applicant:, confirm_result:) }
    let(:step_name) { :confirm_result }

    context 'and the answer is `yes`' do
      let(:confirm_result) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:benefit_check_result_exit, :show, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:confirm_result) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:confirm_details, :edit, id: crime_application) }
    end
  end

  context 'when the step is `confirm_details`' do
    let(:form_object) { double('FormObject', applicant:, confirm_details:) }
    let(:step_name) { :confirm_details }

    context 'and the answer is `yes`' do
      let(:confirm_details) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:benefit_check_result_exit, :show, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:confirm_details) { YesNoAnswer::NO }

      it { is_expected.to have_destination('steps/client/details', :edit, id: crime_application) }
    end
  end
end
