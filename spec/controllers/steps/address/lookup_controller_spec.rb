require 'rails_helper'

RSpec.describe Steps::Address::LookupController, type: :controller do
  it_behaves_like 'an address step controller', Steps::Address::LookupForm, Decisions::AddressDecisionTree do
    describe 'additional actions' do
      let(:form_class) { Steps::Address::LookupForm }
      let(:form_class_params_name) { form_class.name.underscore }

      let(:existing_case) { CrimeApplication.create(applicant: Applicant.new) }
      let(:existing_address) { HomeAddress.find_or_create_by(person: existing_case.applicant) }

      context 'clearing an address' do
        let(:expected_params) do
          {
            :id => existing_case,
            :address_id => existing_address,
            :clear_address => '',
            form_class_params_name => { postcode: 'SW1A 2AA' }
          }
        end

        it 'has the expected step name' do
          expect(
            subject
          ).to receive(:update_and_advance).with(
            form_class,
            record: existing_address,
            as: :clear_address
          )

          put :update, params: expected_params
        end
      end
    end
  end
end
