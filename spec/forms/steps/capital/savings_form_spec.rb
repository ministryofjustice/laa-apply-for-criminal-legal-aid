require 'rails_helper'

RSpec.describe Steps::Capital::SavingsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, client_has_partner:) }
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
      context 'when ownership type is OwnershipType::Partner' do
        let(:ownership) { OwnershiptType::Partner }

        it '`account_holder` is invalid if set to `partner`' do
        end

        it 'errors are added to confirm' do
        end
      end

      describe 'validation of ownership type' do
        it 'is valid if set to' do
        end
      end
    end

    context 'when client has a partner' do
      let(:client_has_partner) { 'yes' }

      it { is_expected.to validate_is_a(:account_holder, OwnershipType) }
    end
  end
end
