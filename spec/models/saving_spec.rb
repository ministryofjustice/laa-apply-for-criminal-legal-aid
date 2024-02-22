require 'rails_helper'

RSpec.describe Saving, type: :model do
  subject(:instance) { described_class.new(attributes) }

  let(:attributes) { { id: nil } }

  describe '#complete?' do
    subject(:complete) { instance.complete? }

    context 'when initialized' do
      it { is_expected.to be false }
    end

    context 'when all provided attributes are present' do
      let(:attributes) do
        {
          id: SecureRandom.uuid,
          crime_application_id: SecureRandom.uuid,
          saving_type: SavingType.values.sample,
          provider_name: 'Bank of Test',
          account_holder: OwnershipType.values.sample,
          sort_code: '01-01-01',
          account_number: '01234500',
          account_balance: '100.01',
          is_overdrawn: YesNoAnswer.values.sample,
          are_wages_paid_into_account: YesNoAnswer.values.sample,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      end

      it { is_expected.to be true }
    end
  end
end
