require 'rails_helper'

RSpec.describe Steps::Capital::SavingsForm do
  subject(:form) { described_class.new(arguments) }
  
  let(:arguments) do
    {
      crime_application:,
      record:
    }
  end

  let(:crime_application) do
    instance_double(CrimeApplication, client_has_partner:)
  end

  let(:record) { Saving.new }
  let(:client_has_partner) { 'no' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider_name) }
    it { is_expected.to validate_presence_of(:sort_code) }
    it { is_expected.to validate_presence_of(:account_number) }
    it { is_expected.to validate_presence_of(:account_balance) }
    it { is_expected.to validate_is_a(:is_overdrawn, YesNoAnswer) }
    it { is_expected.to validate_is_a(:are_wages_paid_into_account, YesNoAnswer) }

    context 'when client has no partner' do
      describe 'errors on `confirm_in_applicants_name`' do
        subject(:error_message) do
          form.errors.full_messages_for(:confirm_in_applicants_name).first
        end

        before do
          form.account_holder = ownership
          form.valid?
        end

        context 'when ownership type is `OwnershipType::Applicant`' do
          let(:ownership) { OwnershipType::APPLICANT }

          it { is_expected.to be_nil }
        end

        context 'when ownership type is `nil`' do
          let(:ownership) { nil }

          it { is_expected.to eq 'Confirm the account is in your client’s name' }
        end

        context 'when ownership type is OwnershipType::Partner' do
          let(:ownership) { OwnershipType::PARTNER }

          it { is_expected.to eq 'Confirm the account is in your client’s name' }
        end
        
        context 'when ownership type is OwnershipType::Partner' do
          let(:ownership) { OwnershipType::APPLICANT_AND_PARTNER }

          it { is_expected.to eq 'Confirm the account is in your client’s name' }
        end
      end
    end

    context 'when client has a partner' do
      let(:client_has_partner) { 'yes' }

      it { is_expected.to validate_is_a(:account_holder, OwnershipType) }
    end
  end

  describe '#confirm_in_applicants_name=(confirm)' do
    subject(:confirm) { form.confirm_in_applicants_name = value }

    context 'when value is true' do
      let(:value) { true }

      it 'sets `#account_holder` to `applicant`' do
        expect { confirm }.to change{ form.account_holder }.from(nil).to(OwnershipType::APPLICANT)
      end

      context 'when client has parter' do
        let(:client_has_partner) { 'yes' }

        it 'does not set the account holder' do
          expect { confirm }.to_not change{ form.account_holder }
        end
      end
    end
    
    context 'when value is false' do
      let(:value) { false }

      it 'does not set the account holder' do
        expect { confirm }.to_not change{ form.account_holder }
      end
    end
    
    context 'when value is nil' do
      let(:value) { nil }

      it 'does not set the account holder' do
        expect { confirm }.to_not change{ form.account_holder }
      end
    end
  end
end
