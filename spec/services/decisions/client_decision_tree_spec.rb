require 'rails_helper'

RSpec.describe Decisions::ClientDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }

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

    it { is_expected.to have_destination(:has_nino, :edit, id: crime_application) }
  end

  context 'when the step is `has_nino`' do
    let(:form_object) { double('FormObject', applicant: 'applicant') }
    let(:step_name) { :has_nino }

    context 'has correct next step' do
      let(:nino) { 'AA123245A' }

      before do
        allow(
          HomeAddress
        ).to receive(:find_or_create_by).with(person: 'applicant').and_return('address')
      end

      it {
        expect(subject).to have_destination('/steps/address/lookup', :edit, id: crime_application,
address_id: 'address')
      }
    end
  end

  context 'when the step is `contact_details`' do
    let(:form_object) do
      double('FormObject', applicant: 'applicant', correspondence_address_type: correspondence_address_type)
    end
    let(:step_name) { :contact_details }

    context 'and answer is `other_address`' do
      let(:correspondence_address_type) { CorrespondenceType::OTHER_ADDRESS }

      before do
        allow(
          CorrespondenceAddress
        ).to receive(:find_or_create_by).with(person: 'applicant').and_return('address')
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
