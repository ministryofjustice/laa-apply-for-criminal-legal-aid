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

      it { is_expected.to have_destination(:benefit_check_result, :edit, id: crime_application) }
    end
  end

  context 'when the step is `benefit_check_result`' do
    let(:form_object) { double('FormObject', applicant:) }
    let(:applicant) { double('Applicant') }
    let(:step_name) { :benefit_check_result }
    let(:confirm_benefit_check_result) { nil }

    context 'and the client has a passporting benefit' do
      before do
        allow(
          applicant
        ).to receive(:passporting_benefit).and_return('Yes')
      end

      context 'has correct next step' do
        before do
          allow(
            HomeAddress
          ).to receive(:find_or_create_by).with(person: applicant).and_return('address')
        end

        it {
          expect(subject).to have_destination('/steps/address/lookup', :edit, id: crime_application,
  address_id: 'address')
        }
      end
    end

    context 'and the client does not have a passporting benefit' do
      before do
        allow(
          applicant
        ).to receive(:passporting_benefit).and_return('No')
      end

      context 'and the caseworker confirms the result' do
        before do
          allow(
            form_object
          ).to receive(:confirm_benefit_check_result).and_return('Yes')
        end

        context 'has correct next step' do
          it {
            expect(subject).to have_destination(:benefit_check_result_exit, :show, id: crime_application)
          }
        end
      end

      context 'and the caseworker does not confirm the result' do
        before do
          allow(
            applicant
          ).to receive(:passporting_benefit).and_return(nil)
        end

        context 'has correct next step' do
          it {
            expect(subject).to have_destination(:confirm_details, :edit, id: crime_application)
          }
        end
      end
    end
  end

  context 'when the step is `confirm_details`' do
    let(:form_object) { double('FormObject', applicant:) }
    let(:applicant) { double('Applicant') }
    let(:step_name) { :confirm_details }

    context 'when the caseworker confirms that the details are correct' do
      before do
        allow(
          form_object
        ).to receive(:confirm_details).and_return('Yes')
      end

      context 'has correct next step' do
        it {
          expect(subject).to have_destination(:benefit_check_result_exit, :show, id: crime_application)
        }
      end
    end

    context 'when the caseworker confirms that the details are incorrect' do
      before do
        allow(
          form_object
        ).to receive(:confirm_details).and_return('No')
      end

      context 'has correct next step' do
        it {
          expect(subject).to have_destination(:details, :edit, id: crime_application)
        }
      end
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
