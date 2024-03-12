require 'rails_helper'

RSpec.describe Steps::Capital::SavingsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
    }.merge(attributes)
  end

  let(:attributes) { {} }

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
          form.ownership_type = ownership
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

        context 'when ownership type is Partner' do
          let(:ownership) { OwnershipType::PARTNER }

          it { is_expected.to eq 'Confirm the account is in your client’s name' }
        end

        context 'when ownership type is Applicant and Partner' do
          let(:ownership) { OwnershipType::APPLICANT_AND_PARTNER }

          it { is_expected.to eq 'Confirm the account is in your client’s name' }
        end
      end
    end

    context 'when client has a partner' do
      let(:client_has_partner) { 'yes' }

      it { is_expected.to validate_is_a(:ownership_type, OwnershipType) }
    end
  end

  describe '#confirm_in_applicants_name=(confirm)' do
    subject(:confirm) do
      form.confirm_in_applicants_name = value
      form.save
    end

    context 'when value is true' do
      let(:value) { true }

      it 'sets `#ownership_type` to `applicant`' do
        expect { confirm }.to change(form, :ownership_type).from(nil).to(OwnershipType::APPLICANT)
      end

      it 'is not persisted (i.e. needs re-confirming)' do
        expect(form.confirm_in_applicants_name).to be_nil
      end

      context 'when client has parter' do
        let(:client_has_partner) { 'yes' }

        it 'does not set the account ownership_type' do
          expect { confirm }.not_to(change(form, :ownership_type))
        end
      end
    end

    context 'when value is false' do
      let(:value) { false }

      it 'does not set the account ownership_type' do
        expect { confirm }.not_to(change(form, :ownership_type))
      end
    end

    context 'when value is nil' do
      let(:value) { nil }

      it 'does not set the account ownership_type' do
        expect { confirm }.not_to(change(form, :ownership_type))
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      let(:attributes) do
        {
          provider_name: 'Bank of Test',
          ownership_type: OwnershipType::APPLICANT,
          sort_code: '01-01-01',
          account_number: '01234500',
          account_balance: '100.01',
          is_overdrawn: YesNoAnswer.values.sample,
          are_wages_paid_into_account: YesNoAnswer.values.sample,
          confirm_in_applicants_name: YesNoAnswer::YES
        }
      end

      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
