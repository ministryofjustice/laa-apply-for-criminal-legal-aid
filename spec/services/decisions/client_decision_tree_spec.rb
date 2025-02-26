require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Decisions::ClientDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant, case: kase) }
  let(:applicant) { instance_double(Applicant) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { CaseType::SUMMARY_ONLY }

  let(:appeal_no_changes?) { nil }
  let(:has_partner) { nil }
  let(:not_means_tested?) { nil }
  let(:cifc?) { false }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)

    allow(crime_application).to receive_messages(
      update: true,
      date_stamp: nil,
      date_stamp_context: nil,
      appeal_no_changes?: appeal_no_changes?,
      not_means_tested?: not_means_tested?,
      cifc?: cifc?,
    )

    allow(crime_application).to receive(:date_stamp_context=)
    allow(DateStampContext).to receive(:build).and_return(nil)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `has_partner`' do
    let(:form_object) { double('FormObject', has_partner:) }
    let(:step_name) { :has_partner }
    let(:applicant) { instance_double(Applicant) }

    context 'and answer is `no`' do
      let(:has_partner) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:relationship_status, :edit, id: crime_application) }
    end

    context 'and answer is `yes`' do
      let(:has_partner) { YesNoAnswer::YES }

      it { is_expected.to have_destination('/steps/partner/relationship', :edit, id: crime_application) }
    end
  end

  context 'when the step is relationship status' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :relationship_status }

    context 'when applicant has an arc number' do
      before do
        allow(applicant).to receive(:arc).and_return('ABC12/345678/A')
      end

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end

    context 'when applicant does not have an arc' do
      before do
        allow(applicant).to receive(:arc).and_return(nil)
      end

      it { is_expected.to have_destination('/steps/dwp/benefit_type', :edit, id: crime_application) }
    end
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :details }

    context 'and `non_means_tested`' do
      it { is_expected.to have_destination(:is_means_tested, :edit, id: crime_application) }
    end

    context 'and `non_means_tested` and change in financial circumstances application' do
      let(:cifc?) { true }

      it { is_expected.to have_destination(:case_type, :edit, id: crime_application) }
    end
  end

  context 'when the step is `is_means_tested`' do
    let(:form_object) { double('FormObject', is_means_tested:) }
    let(:step_name) { :is_means_tested }

    context 'when answer is `yes`' do
      let(:is_means_tested) { YesNoAnswer::YES }

      it { is_expected.to have_destination(:case_type, :edit, id: crime_application) }
    end

    context 'when answer is `no`' do
      let(:is_means_tested) { YesNoAnswer::NO }
      let(:not_means_tested?) { true }

      context 'and the application already has a date stamp' do
        before do
          allow(crime_application).to receive(:date_stamp) { Time.zone.today }
        end

        it { is_expected.to have_destination(:residence_type, :edit, id: crime_application) }
      end

      context 'and the application has no date stamp' do
        before do
          allow(crime_application).to receive(:date_stamp=)
          allow(crime_application).to receive(:save).and_return(true)
        end

        it { is_expected.to have_destination(:date_stamp, :edit, id: crime_application) }
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

      it { is_expected.to have_destination(:residence_type, :edit, id: crime_application) }
    end

    context 'and the application has no date stamp' do
      before do
        allow(crime_application).to receive(:date_stamp)
      end

      context 'and the case type is "date stampable"' do
        let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

        before do
          allow(crime_application).to receive(:date_stamp=)
          allow(crime_application).to receive(:save).and_return(true)
        end

        it { is_expected.to have_destination(:date_stamp, :edit, id: crime_application) }
      end

      context 'and case type is not "date stampable"' do
        let(:case_type) { CaseType::INDICTABLE.to_s }

        before do
          allow(
            Address
          ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
        end

        it { is_expected.to have_destination(:residence_type, :edit, id: crime_application) }
      end
    end

    context 'with a change_in_financial_circumstances application' do
      let(:cifc?) { true }

      before do
        allow(crime_application).to receive(:date_stamp=)
        allow(crime_application).to receive(:save).and_return(true)
      end

      it { is_expected.to have_destination(:date_stamp, :edit, id: crime_application) }
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

    context 'when the case type is not appeal to Crown Court' do
      let(:case_type) { CaseType::INDICTABLE }

      it { is_expected.to have_destination(:residence_type, :edit, id: crime_application) }
    end

    context 'when the case type is appeal_to_crown_court and a reference number was entered' do
      let(:appeal_no_changes?) { true }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end

    context 'when the case type is appeal_to_crown_court and no reference number was entered' do
      let(:appeal_no_changes?) { false }

      it { is_expected.to have_destination(:residence_type, :edit, id: crime_application) }
    end

    context 'when the case type is not present' do
      let(:case_type) { nil }

      it { is_expected.to have_destination(:residence_type, :edit, id: crime_application) }
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

        it { is_expected.to have_destination('steps/shared/nino', :edit, id: crime_application, subject: 'client') }
      end

      context 'and answer is `providers_office_address`' do
        let(:correspondence_address_type) { CorrespondenceType::PROVIDERS_OFFICE_ADDRESS }

        it { is_expected.to have_destination('steps/shared/nino', :edit, id: crime_application, subject: 'client') }
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

  context 'when the step is `nino`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :nino }

    context 'when the application is means tested' do
      let(:not_means_tested?) { false }

      it { is_expected.to have_destination('/steps/client/has_partner', :edit, id: crime_application) }
    end

    context 'when the application is not means tested' do
      let(:not_means_tested?) { true }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end
  end

  context 'when the step is `residence_type`' do
    let(:form_object) { double('FormObject', applicant:, residence_type:) }
    let(:step_name) { :residence_type }

    context 'and the answer is `none`' do
      let(:residence_type) { ResidenceType::NONE }

      it { is_expected.to have_destination(:contact_details, :edit, id: crime_application) }
    end

    context 'and the answer is any other type' do
      let(:residence_type) { ResidenceType::PARENTS }

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

    context 'and they previously entered an address manually' do
      let(:residence_type) { ResidenceType::RENTED }
      let(:address) { Address.new(lookup_id: nil) }

      before do
        allow(
          Address
        ).to receive(:find_by).with(person: applicant).and_return(address)
      end

      it {
        expect(subject).to have_destination(
          '/steps/address/details',
          :edit,
          id: crime_application,
          address_id: address
        )
      }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
