require 'rails_helper'

RSpec.describe Decisions::DWPDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:applicant) { instance_double(Applicant, passporting_benefit:) }
  let(:passporting_benefit) { false }

  before do
    allow(
      form_object
    ).to receive_messages(crime_application:, applicant:)
  end

  it_behaves_like 'a decision tree'

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

      it { is_expected.to have_destination('steps/client/has_benefit_evidence', :edit, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:confirm_details) { YesNoAnswer::NO }

      it { is_expected.to have_destination('steps/client/details', :edit, id: crime_application) }
    end
  end

  context 'when the step is `cannot_check_dwp_status`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :cannot_check_dwp_status }

    it { is_expected.to have_destination('steps/client/has_benefit_evidence', :edit, id: crime_application) }
  end
end
