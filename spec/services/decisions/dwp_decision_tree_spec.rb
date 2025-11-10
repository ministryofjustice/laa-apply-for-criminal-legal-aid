require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Decisions::DWPDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) {
    instance_double(CrimeApplication, partner: partner, partner_detail: partner_detail,
  non_means_tested?: false)
  }
  let(:applicant) { double(Applicant, type: 'Applicant') }
  let(:benefit_check_subject) { applicant }
  let(:partner) { nil }
  let(:has_passporting_benefit) { false }
  let(:partner_detail) { nil }

  before do
    allow(
      form_object
    ).to receive_messages(crime_application:, applicant:)
  end

  it_behaves_like 'a decision tree'

  context 'when dwp undetermined feature is enabled' do
    before do
      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }
    end

    context 'when the step is `confirm_result`' do
      let(:form_object) { double('FormObject') }
      let(:step_name) { :confirm_result }

      context 'when the partners benefit check is required' do
        let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'none') }

        it { is_expected.to have_destination(:partner_benefit_type, :edit, id: crime_application) }
      end

      context 'when the partners benefit check is not required' do
        it { is_expected.to have_destination('steps/case/urn', :edit, id: crime_application) }
      end
    end

    context 'when the step is `partner_confirm_result`' do
      let(:form_object) { double('FormObject') }
      let(:step_name) { :partner_confirm_result }

      it { is_expected.to have_destination('steps/case/urn', :edit, id: crime_application) }
    end
  end

  context 'when dwp undetermined feature is disabled' do
    let(:applicant) { double(Applicant, benefit_check_result: benefit_check_result, type: 'Applicant') }
    let(:benefit_check_result) { false }

    context 'when the step is `confirm_result`' do
      let(:form_object) { double('FormObject', applicant:, confirm_dwp_result:) }
      let(:step_name) { :confirm_result }

      context 'and the answer is `yes`' do
        let(:confirm_dwp_result) { YesNoAnswer::YES }
        let(:applicant) { double(Applicant, benefit_type:) }
        let(:benefit_type) { BenefitType::NONE.to_s }

        before do
          allow(crime_application).to receive_messages(applicant:)
          allow(applicant).to receive_messages(benefit_type:)
        end

        context 'when the partners benefit check is required' do
          let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'none') }

          it { is_expected.to have_destination(:partner_benefit_type, :edit, id: crime_application) }
        end

        context 'when the partners benefit check is not required' do
          it { is_expected.to have_destination('steps/case/urn', :edit, id: crime_application) }
        end
      end

      context 'and the answer is `no`' do
        let(:confirm_dwp_result) { YesNoAnswer::NO }

        it { is_expected.to have_destination(:confirm_details, :edit, id: crime_application) }
      end
    end

    context 'when the step is `partner_confirm_result`' do
      let(:form_object) { double('FormObject', applicant:, confirm_dwp_result:) }
      let(:step_name) { :partner_confirm_result }

      context 'and the answer is `yes`' do
        let(:confirm_dwp_result) { YesNoAnswer::YES }

        it { is_expected.to have_destination('steps/case/urn', :edit, id: crime_application) }
      end

      context 'and the answer is `no`' do
        let(:confirm_dwp_result) { YesNoAnswer::NO }

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

        context 'when the benefit check recipient is the applicant' do
          it { is_expected.to have_destination('steps/client/details', :edit, id: crime_application) }
        end

        context 'when the benefit check recipient is the partner' do
          let(:partner) { double(Partner, has_passporting_benefit?: has_passporting_benefit) }
          let(:has_passporting_benefit) { true }

          it { is_expected.to have_destination('steps/partner/details', :edit, id: crime_application) }
        end
      end
    end
  end

  context 'when the step is `confirm_details`' do
    let(:form_object) { double('FormObject', confirm_details:) }
    let(:step_name) { :confirm_details }

    context 'and the answer is `yes`' do
      let(:confirm_details) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:has_benefit_evidence, :edit, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:confirm_details) { YesNoAnswer::NO }

      context 'when the benefit check recipient is the applicant' do
        it { is_expected.to have_destination('steps/client/details', :edit, id: crime_application) }
      end

      context 'when the benefit check recipient is the partner' do
        let(:partner) { double(Partner, has_passporting_benefit?: has_passporting_benefit) }
        let(:has_passporting_benefit) { true }

        it { is_expected.to have_destination('steps/partner/details', :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `benefit_type`' do
    let(:form_object) { double('FormObject', benefit_type:) }
    let(:applicant_double) { double(Applicant, has_nino: has_nino, type: 'Applicant') }
    let(:step_name) { :benefit_type }
    let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT }
    let(:has_nino) { YesNoAnswer::YES.to_s }
    let(:partner_double) { nil }
    let(:arc) { nil }
    let(:benefit_check_result) { nil }
    let(:dwp_response) { nil }

    before do
      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      allow(crime_application).to receive_messages(applicant: applicant_double, partner: partner_double,
                                                   benefit_check_passported?: benefit_check_passported)

      allow(applicant_double).to receive_messages(benefit_check_result:, dwp_response:)

      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(applicant_double).and_return(true)
    end

    context 'and the benefit type is `none`' do
      let(:benefit_type) { BenefitType::NONE }
      let(:benefit_check_passported) { false }

      context 'and the partner is included in the means assessment' do
        let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'none') }

        it { is_expected.to have_destination(:partner_benefit_type, :edit, id: crime_application) }
      end

      context 'and the partner is not included in the means assessment' do
        let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'victim') }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end

      context 'and the partner has an arc number' do
        let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'victim') }
        let(:partner_double) { instance_double(Partner, arc:) }
        let(:arc) { 'ABC12/345678/A' }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end
    end

    context 'when application has been already passported on benefit check' do
      let(:benefit_check_passported) { true }

      it { is_expected.to have_destination(:benefit_check_result, :edit, id: crime_application) }
    end

    context 'when application does not have an existing passporting on benefit check' do
      let(:benefit_check_passported) { false }

      context 'when the applicant has a passporting benefit' do
        context 'has correct next step' do
          let(:benefit_check_result) { true }

          it { is_expected.to have_destination(:benefit_check_result, :edit, id: crime_application) }
        end
      end

      context 'when the applicant does not have a passporting benefit' do
        context 'has correct next step' do
          let(:benefit_check_result) { false }

          it { is_expected.to have_destination(:confirm_result, :edit, id: crime_application) }
        end
      end

      context 'when the benefit check result is `Undetermined`' do
        context 'has correct next step' do
          let(:benefit_check_result) { false }
          let(:dwp_response) { 'Undetermined' }

          it { is_expected.to have_destination(:cannot_match_details, :edit, id: crime_application) }
        end
      end

      context 'when the benefit checker cannot check on the status of the passporting benefit' do
        context 'has correct next step' do
          it { is_expected.to have_destination(:cannot_check_dwp_status, :edit, id: crime_application) }
        end
      end
    end

    context 'when the applicant does not have a nino' do
      let(:benefit_check_passported) { false }
      let(:has_nino) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:cannot_check_benefit_status, :edit, id: crime_application) }
    end
  end

  context 'when the step is `partner_benefit_type`' do
    # The dwp check decision tree has been tested for the benefit type step so this does not test all routes

    let(:form_object) { double('FormObject', benefit_type:) }
    let(:partner_double) { double(Partner, has_nino:) }
    let(:step_name) { :partner_benefit_type }
    let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT }
    let(:has_nino) { YesNoAnswer::YES }
    let(:benefit_check_passported) { false }

    before do
      allow(crime_application).to receive_messages(partner: partner_double,
                                                   benefit_check_passported?: benefit_check_passported)

      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(partner_double).and_return(true)
    end

    context 'and the benefit type is `none`' do
      let(:benefit_type) { BenefitType::NONE }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end

    context 'when the partner does not have a nino' do
      let(:has_nino) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:cannot_check_benefit_status, :edit, id: crime_application) }
    end
  end

  context 'when the step is `has_benefit_evidence`' do
    let(:form_object) { double('FormObject', applicant:, has_benefit_evidence:) }
    let(:step_name) { :has_benefit_evidence }

    context 'and the answer is `yes`' do
      let(:has_benefit_evidence) { YesNoAnswer::YES }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end

    context 'and the answer is `no`' do
      let(:has_benefit_evidence) { YesNoAnswer::NO }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end
  end

  context 'when the step is `benefit_check_result`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :benefit_check_result }

    it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
  end

  context 'when the step is `cannot_check_benefit_status`' do
    let(:form_object) { double('FormObject', applicant:, will_enter_nino:) }
    let(:step_name) { :cannot_check_benefit_status }

    context 'and the answer is `yes`' do
      let(:will_enter_nino) { YesNoAnswer::YES }

      context 'when the benefit check recipient is the applicant' do
        it { is_expected.to have_destination('steps/shared/nino', :edit, id: crime_application, subject: 'client') }
      end

      context 'when the benefit check recipient is the partner' do
        let(:has_passporting_benefit) { true }
        let(:partner) { double(Partner, has_passporting_benefit?: has_passporting_benefit) }

        it { is_expected.to have_destination('steps/shared/nino', :edit, id: crime_application, subject: 'partner') }
      end
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
    let(:benefit_check_result) { false }
    let(:dwp_response) { 'No' }
    let(:benefit_check_subject) { applicant }

    before do
      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      allow(crime_application).to receive_messages(applicant: applicant,
                                                   partner: partner,
                                                   benefit_check_passported?: benefit_check_passported)

      allow(applicant).to receive_messages(benefit_check_result:, dwp_response:)

      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(applicant).and_return(true)
    end

    it { is_expected.to have_destination(:confirm_result, :edit, id: crime_application) }

    context 'when benefit check is performed on partner details' do
      let(:partner_has_benefit) { true }
      let(:benefit_check_subject) { partner }

      before do
        allow(partner).to receive_messages(benefit_check_result:, dwp_response:)

        allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(partner).and_return(true)
      end

      it { is_expected.to have_destination(:confirm_result, :edit, id: crime_application) }
    end

    context 'when dwp undetermined feature is disabled' do
      let(:benefit_check_result) { false }

      before do
        allow(FeatureFlags).to receive(:dwp_undetermined) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }

        allow(applicant).to receive_messages(benefit_check_result:)
      end

      it { is_expected.to have_destination(:confirm_result, :edit, id: crime_application) }
    end
  end

  context 'when the step is `cannot_match_details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :cannot_match_details }

    it { is_expected.to have_destination(:confirm_details, :edit, id: crime_application) }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
