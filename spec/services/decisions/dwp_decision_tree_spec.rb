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

      before do
        allow(FeatureFlags).to receive(:means_journey) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: means_enabled?)
        }
      end

      context 'with means journey enabled' do
        let(:means_enabled?) { true }

        it { is_expected.to have_destination('steps/case/urn', :edit, id: crime_application) }
      end

      context 'with means journey disabled' do
        let(:means_enabled?) { false }

        it { is_expected.to have_destination(:benefit_check_result_exit, :show, id: crime_application) }
      end
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

      it { is_expected.to have_destination(:has_benefit_evidence, :edit, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:confirm_details) { YesNoAnswer::NO }

      it { is_expected.to have_destination('steps/client/details', :edit, id: crime_application) }
    end
  end

  context 'when the step is `benefit_type`' do
    let(:form_object) { double('FormObject', benefit_type:) }
    let(:applicant_double) { double(Applicant, has_nino:) }
    let(:step_name) { :benefit_type }
    let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT }
    let(:has_nino) { YesNoAnswer::YES }
    let(:feature_flag_means_journey_enabled) { false }

    before do
      allow(crime_application).to receive_messages(applicant: applicant_double,
                                                   benefit_check_passported?: benefit_check_passported)

      allow(applicant_double).to receive_messages(passporting_benefit:)

      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(applicant_double).and_return(true)

      allow(FeatureFlags).to receive(:means_journey) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: feature_flag_means_journey_enabled)
      }
    end

    context 'and the benefit type is `none`' do
      let(:feature_flag_means_journey_enabled) { false }
      let(:benefit_type) { BenefitType::NONE }
      let(:benefit_check_passported) { false }
      let(:passporting_benefit) { nil }

      it { is_expected.to have_destination(:benefit_exit, :show, id: crime_application) }

      context 'and feature flag `means_journey` is enabled' do
        let(:feature_flag_means_journey_enabled) { true }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end
    end

    context 'when application has been already passported on benefit check' do
      let(:benefit_check_passported) { true }
      let(:passporting_benefit) { nil }

      it { is_expected.to have_destination(:benefit_check_result, :edit, id: crime_application) }
    end

    context 'when application does not have an existing passporting on benefit check' do
      let(:benefit_check_passported) { false }

      context 'when the applicant has a passporting benefit' do
        context 'has correct next step' do
          let(:passporting_benefit) { true }

          it { is_expected.to have_destination(:benefit_check_result, :edit, id: crime_application) }
        end
      end

      context 'when the applicant does not have a passporting benefit' do
        context 'has correct next step' do
          let(:passporting_benefit) { false }

          it { is_expected.to have_destination(:confirm_result, :edit, id: crime_application) }
        end
      end

      context 'when the benefit checker cannot check on the status of the passporting benefit' do
        context 'has correct next step' do
          let(:passporting_benefit) { nil }

          it { is_expected.to have_destination(:cannot_check_dwp_status, :edit, id: crime_application) }
        end
      end
    end

    context 'when the applicant does not have a nino' do
      let(:passporting_benefit) { nil }
      let(:benefit_check_passported) { false }
      let(:has_nino) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:cannot_check_dwp_status, :edit, id: crime_application) }

      context 'and feature flag `means_journey` is enabled' do
        let(:feature_flag_means_journey_enabled) { true }

        it { is_expected.to have_destination(:cannot_check_benefit_status, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `has_benefit_evidence`' do
    let(:form_object) { double('FormObject', applicant:, has_benefit_evidence:) }
    let(:step_name) { :has_benefit_evidence }
    let(:feature_flag_means_journey_enabled) { true }

    before do
      allow(FeatureFlags).to receive(:means_journey) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: feature_flag_means_journey_enabled)
      }
    end

    context 'and the answer is `yes`' do
      let(:has_benefit_evidence) { YesNoAnswer::YES }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:has_benefit_evidence) { YesNoAnswer::NO }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end

    context 'and the answer is `no` for a non means tested application' do
      let(:feature_flag_means_journey_enabled) { false }
      let(:has_benefit_evidence) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:evidence_exit, :show, id: crime_application) }
    end
  end

  context 'when the step is `benefit_check_result`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :benefit_check_result }

    it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
  end

  context 'when the step is `after_cannot_check_benefit_status`' do
    let(:form_object) { double('FormObject', applicant:, will_enter_nino:) }
    let(:step_name) { :cannot_check_benefit_status }

    context 'and the answer is `yes`' do
      let(:will_enter_nino) { YesNoAnswer::YES }

      it { is_expected.to have_destination('steps/client/has_nino', :edit, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:will_enter_nino) { YesNoAnswer::NO }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end
  end

  context 'when the step is `cannot_check_dwp_status`' do
    # The dwp check decision tree has been tested for the benefit type step so this does not test all routes

    let(:form_object) { double('FormObject') }
    let(:step_name) { :cannot_check_dwp_status }
    let(:benefit_check_passported) { false }
    let(:passporting_benefit) { false }
    let(:applicant_double) { double(Applicant) }

    before do
      allow(crime_application).to receive_messages(applicant: applicant_double,
                                                   benefit_check_passported?: benefit_check_passported)

      allow(applicant_double).to receive_messages(passporting_benefit:)

      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(applicant_double).and_return(true)
    end

    it { is_expected.to have_destination(:confirm_result, :edit, id: crime_application) }
  end
end
