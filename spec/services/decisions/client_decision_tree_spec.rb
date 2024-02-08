require 'rails_helper'

RSpec.describe Decisions::ClientDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant) }
  let(:kase) { instance_double(Case) }

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

    context 'and the case type is `appeal_to_crown_court_with_changes`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }

      it { is_expected.to have_destination(:appeal_details, :edit, id: crime_application) }
    end

    context 'and the application already has a date stamp' do
      before do
        allow(crime_application).to receive(:date_stamp) { Time.zone.today }
        allow(kase).to receive(:case_type).and_return(case_type)

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
        allow(kase).to receive(:case_type).and_return(case_type)
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
    let(:form_object) { double('FormObject') }
    let(:step_name) { :appeal_details }

    # We've tested this logic for non-appeals, no need to test again
    # as this step runs the same method/code
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

  context 'when the step is `benefit_type`' do
    let(:form_object) { double('FormObject', benefit_type:) }
    let(:applicant_double) { double(Applicant) }
    let(:step_name) { :benefit_type }
    let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT }

    before do
      allow(crime_application).to receive_messages(applicant: applicant_double,
                                                   benefit_check_passported?: benefit_check_passported)

      allow(applicant_double).to receive_messages(passporting_benefit:)

      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(applicant_double).and_return(true)
    end

    context 'and the benefit type is `none`' do
      let(:benefit_type) { BenefitType::NONE }
      let(:benefit_check_passported) { false }
      let(:passporting_benefit) { nil }

      it { is_expected.to have_destination(:benefit_exit, :show, id: crime_application) }
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

          it { is_expected.to have_destination(:retry_benefit_check, :edit, id: crime_application) }
        end
      end
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

      it { is_expected.to have_destination(:evidence_exit, :show, id: crime_application) }
    end
  end

  context 'when the step is `retry_benefit_check`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :retry_benefit_check }

    it 'runs the `determine_dwp_result_page` logic' do
      expect(subject).to receive(:determine_dwp_result_page)
      subject.destination
    end
  end

  context 'when the step is `benefit_check_result`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :benefit_check_result }

    it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
  end
end
