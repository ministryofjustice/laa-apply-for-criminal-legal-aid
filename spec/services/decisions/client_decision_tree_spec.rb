require 'rails_helper'

RSpec.describe Decisions::ClientDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant, case: kase) }
  let(:applicant) { instance_double(Applicant) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { CaseType::SUMMARY_ONLY }

  let(:not_means_tested) { nil }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)

    allow(crime_application).to receive_messages(update: true, date_stamp: nil, not_means_tested?: not_means_tested)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `is_means_tested`' do
    let(:form_object) { double('FormObject', is_means_tested:) }
    let(:step_name) { :is_means_tested }

    context 'and answer is `yes`' do
      let(:is_means_tested) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:has_partner, :edit, id: crime_application) }
    end

    context 'and answer is `no`' do
      let(:is_means_tested) { YesNoAnswer::NO }

      it { is_expected.to have_destination('/crime_applications', :edit, id: crime_application) }
    end
  end

  context 'when the step is `has_partner`' do
    let(:form_object) { double('FormObject', client_has_partner:) }
    let(:step_name) { :has_partner }

    context 'and answer is `no`' do
      let(:client_has_partner) { YesNoAnswer::NO }

      it { is_expected.to have_destination('/crime_applications', :edit, id: crime_application) }
    end

    context 'and answer is `yes`' do
      let(:client_has_partner) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:partner_exit, :show, id: crime_application) }
    end
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :details }

    before do
      allow(crime_application).to receive(:is_means_tested?).and_return(is_means_tested)
    end

    context 'and application is means tested' do
      let(:is_means_tested) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:case_type, :edit, id: crime_application) }
    end

    context 'and application is not means tested' do
      let(:is_means_tested) { YesNoAnswer::NO }
      let(:not_means_tested) { true }

      context 'and application does not already have a date stamp' do
        it { is_expected.to have_destination(:date_stamp, :edit, id: crime_application) }
      end

      context 'and application already has a date stamp' do
        before do
          allow(crime_application).to receive(:date_stamp) { Time.zone.today }
          allow(
            Address
          ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
        end

        let(:is_means_tested) { YesNoAnswer::NO }
        let(:not_means_tested) { true }

        it {
          expect(subject).to have_destination(
            '/steps/address/lookup',
            :edit,
            id: crime_application,
            address_id: 'address'
          )
        }
      end
    end
  end

  context 'when the step is `case_type`' do
    let(:form_object) { double('FormObject', case: kase, case_type: CaseType.new(case_type)) }
    let(:step_name) { :case_type }

    context 'and the case type is `appeal_to_crown_court`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it { is_expected.to have_destination(:appeal_details, :edit, id: crime_application) }
    end

    context 'and the application already has a date stamp' do
      before do
        allow(crime_application).to receive(:date_stamp) { Time.zone.today }

        allow(
          Address
        ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
      end

      let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

      it {
        expect(subject).to have_destination(
          '/steps/address/lookup',
          :edit,
          id: crime_application,
          address_id: 'address'
        )
      }
    end

    context 'and the application has no date stamp' do
      before do
        allow(crime_application).to receive(:date_stamp)
      end

      context 'and the case type is "date stampable"' do
        let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

        it { is_expected.to have_destination(:date_stamp, :edit, id: crime_application) }
      end

      context 'and case type is not "date stampable"' do
        let(:case_type) { CaseType::INDICTABLE.to_s }

        before do
          allow(
            Address
          ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
        end

        it {
          expect(subject).to have_destination(
            '/steps/address/lookup',
            :edit,
            id: crime_application,
            address_id: 'address'
          )
        }
      end
    end
  end

  context 'when the step is `appeal_details`' do
    let(:form_object) { double('FormObject', appeal_original_app_submitted:) }
    let(:step_name) { :appeal_details }

    context 'and a legal aid application was submitted for the original case' do
      let(:appeal_original_app_submitted) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:appeal_financial_circumstances, :edit, id: crime_application) }
    end

    context 'and a legal aid application was not submitted for the original case' do
      let(:appeal_original_app_submitted) { YesNoAnswer::NO }

      it 'performs the date stamp logic' do
        expect(subject).to receive(:date_stamp_if_needed)
        subject.destination
      end
    end
  end

  context 'when the step is `appeal_financial_circumstances`' do
    let(:form_object) { double('FormObject', appeal_financial_circumstances_changed:) }
    let(:step_name) { :appeal_financial_circumstances }

    context 'and the answer is yes, financial circumstances have changed' do
      let(:appeal_financial_circumstances_changed) { YesNoAnswer::YES }

      it 'performs the date stamp logic' do
        expect(subject).to receive(:date_stamp_if_needed)
        subject.destination
      end
    end

    context 'and the answer is no, financial circumstances have not changed' do
      let(:appeal_financial_circumstances_changed) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:appeal_reference_number, :edit, id: crime_application) }
    end
  end

  context 'when the step is `appeal_reference_number`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :appeal_reference_number }

    it 'performs the date stamp logic' do
      expect(subject).to receive(:date_stamp_if_needed)
      subject.destination
    end
  end

  context 'when the step is `date_stamp`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :date_stamp }

    before do
      allow(
        Address
      ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
      allow(crime_application).to receive(:date_stamp)
    end

    context 'when the case type is not appeal to crown court' do
      let(:case_type) { CaseType::INDICTABLE }

      it {
        expect(subject).to have_destination(
          '/steps/address/lookup',
          :edit,
          id: crime_application,
          address_id: 'address'
        )
      }
    end

    context 'when the case type is appeal_to_crown_court and a reference number was entered' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT }

      before do
        allow(kase).to receive(:appeal_reference_number).and_return('appeal_maat_id')
      end

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end

    context 'when the case type is appeal_to_crown_court and no reference number was entered' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT }

      before do
        allow(kase).to receive(:appeal_reference_number).and_return(nil)
      end

      it {
        expect(subject).to have_destination(
          '/steps/address/lookup',
          :edit,
          id: crime_application,
          address_id: 'address'
        )
      }
    end

    context 'when the case type is not present' do
      let(:case_type) { nil }

      it {
        expect(subject).to have_destination(
          '/steps/address/lookup',
          :edit,
          id: crime_application,
          address_id: 'address'
        )
      }
    end
  end

  context 'when the step is `contact_details`' do
    let(:form_object) { double('FormObject', correspondence_address_type:) }
    let(:step_name) { :contact_details }

    context 'and answer is `other_address`' do
      let(:correspondence_address_type) { CorrespondenceType::OTHER_ADDRESS }

      before do
        allow(
          CorrespondenceAddress
        ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
      end

      it {
        expect(subject).to have_destination(
          '/steps/address/lookup',
          :edit,
          id: crime_application,
          address_id: 'address'
        )
      }
    end

    context 'and applicant is not `age_passported`' do
      before do
        allow(crime_application).to receive(:age_passported?).and_return(false)
      end

      context 'and answer is `home_address`' do
        let(:correspondence_address_type) { CorrespondenceType::HOME_ADDRESS }

        it { is_expected.to have_destination(:has_nino, :edit, id: crime_application) }
      end

      context 'and answer is `providers_office_address`' do
        let(:correspondence_address_type) { CorrespondenceType::PROVIDERS_OFFICE_ADDRESS }

        it { is_expected.to have_destination(:has_nino, :edit, id: crime_application) }
      end
    end

    context 'and applicant is `age_passported`' do
      before do
        allow(crime_application).to receive(:age_passported?).and_return(true)
      end

      context 'and answer is `home_address`' do
        let(:correspondence_address_type) { CorrespondenceType::HOME_ADDRESS }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end

      context 'and answer is `providers_office_address`' do
        let(:correspondence_address_type) { CorrespondenceType::PROVIDERS_OFFICE_ADDRESS }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `has_nino`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :has_nino }

    context 'when the application is means tested' do
      it { is_expected.to have_destination(:benefit_type, :edit, id: crime_application) }
    end

    context 'when the application is not means tested' do
      let(:not_means_tested) { true }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
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

          it { is_expected.to have_destination('steps/dwp/confirm_result', :edit, id: crime_application) }
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
  # rubocop:enable RSpec/MultipleMemoizedHelpers

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

      it { is_expected.to have_destination(:has_nino, :edit, id: crime_application) }
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

    it { is_expected.to have_destination('steps/dwp/confirm_result', :edit, id: crime_application) }
  end
end
