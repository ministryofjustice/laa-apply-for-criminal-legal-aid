require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Saving do
  subject { described_class.generate(savings) }

  let(:savings) { [saving1, saving2] }
  let(:include_partner?) { true }

  let(:saving1) do
    instance_double(
      Saving,
      saving_type: 'bank',
      provider_name: 'Test Bank',
      ownership_type: 'applicant',
      sort_code: '01-01-01',
      account_number: '01234500',
      account_balance_before_type_cast: 10_001,
      is_overdrawn: 'yes',
      are_wages_paid_into_account: 'yes',
      are_partners_wages_paid_into_account: 'no',
      include_partner_in_means_assessment?: false
    )
  end

  let(:saving2) do
    instance_double(
      Saving,
      saving_type: 'building_society',
      provider_name: 'Test Building Society',
      ownership_type: 'applicant',
      sort_code: '12-34-56',
      account_number: '01234500',
      account_balance_before_type_cast: 200_050,
      is_overdrawn: 'no',
      are_wages_paid_into_account: 'no',
      are_partners_wages_paid_into_account: 'yes',
      include_partner_in_means_assessment?: true
    )
  end

  let(:json_output) do
    [
      {
        saving_type: 'bank',
        provider_name: 'Test Bank',
        ownership_type: 'applicant',
        sort_code: '01-01-01',
        account_number: '01234500',
        account_balance: 10_001,
        is_overdrawn: 'yes',
        are_wages_paid_into_account: 'yes',
      },
      {
        saving_type: 'building_society',
        provider_name: 'Test Building Society',
        ownership_type: 'applicant',
        sort_code: '12-34-56',
        account_number: '01234500',
        account_balance: 200_050,
        is_overdrawn: 'no',
        are_wages_paid_into_account: 'no',
        are_partners_wages_paid_into_account: 'yes'
      },
    ].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
