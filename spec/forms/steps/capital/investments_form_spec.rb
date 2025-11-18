require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
    }.merge(attributes)
  end
  let(:record) { Investment.new }
  let(:include_partner?) { false }

  let(:attributes) { {} }

  let(:crime_application) do
    instance_double(CrimeApplication)
  end

  before do
    allow(form).to receive(:include_partner_in_means_assessment?) { include_partner? }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:value) }

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

          it { is_expected.to eq 'Confirm the investment is in your client’s name' }
        end

        context 'when ownership type is Partner' do
          let(:ownership) { OwnershipType::PARTNER }

          it { is_expected.to eq 'Confirm the investment is in your client’s name' }
        end

        context 'when ownership type is Applicant and Partner' do
          let(:ownership) { OwnershipType::APPLICANT_AND_PARTNER }

          it { is_expected.to eq 'Confirm the investment is in your client’s name' }
        end
      end
    end

    context 'when client has a partner' do
      let(:include_partner?) { true }

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

      context 'when client has partner' do
        let(:include_partner?) { true }

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
          description: 'About my Bonds',
          ownership_type: OwnershipType::APPLICANT,
          value: '100.01',
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
