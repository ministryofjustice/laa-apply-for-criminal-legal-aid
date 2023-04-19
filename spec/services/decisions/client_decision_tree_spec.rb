require 'rails_helper'

RSpec.describe Decisions::ClientDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant) }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

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
      allow(crime_application).to receive(:age_passported?).and_return(age_passported)
    end

    context 'and client is age passported' do
      let(:age_passported) { true }

      before do
        allow(
          Address
        ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
      end

      it {
        expect(subject).to have_destination('/steps/address/lookup', :edit, id: crime_application,
          address_id: 'address')
      }
    end

    context 'and client is not age passported' do
      let(:age_passported) { false }

      it { is_expected.to have_destination(:has_nino, :edit, id: crime_application) }
    end
  end

  context 'when the step is `has_nino`' do
    let(:form_object) { double('FormObject') }
    let(:applicant_double) { double(Applicant) }
    let(:step_name) { :has_nino }
    let(:nino) { 'AA123245A' }

    before do
      allow(crime_application).to receive(:applicant).and_return(applicant_double)
      allow(DWP::UpdateBenefitCheckResultService).to receive(:call).with(applicant_double).and_return(true)
      allow(applicant_double).to receive(:passporting_benefit?).and_return(passporting_benefit)
      allow(applicant_double).to receive(:passporting_benefit).and_return(passporting_benefit)

      allow(crime_application).to receive(:benefit_check_passported?).and_return(benefit_check_passported)
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

  context 'when the step is `retry_benefit_check`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :retry_benefit_check }

    it 'runs the same logic as the `has_nino` step' do
      expect(subject).to receive(:after_has_nino)
      subject.destination
    end
  end

  context 'when the step is `benefit_check_result`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :benefit_check_result }

    before do
      allow(
        Address
      ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
    end

    it {
      expect(subject).to have_destination('/steps/address/lookup', :edit, id: crime_application,
  address_id: 'address')
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
        expect(subject).to have_destination('/steps/address/lookup', :edit, id: crime_application,
address_id: 'address')
      }
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
