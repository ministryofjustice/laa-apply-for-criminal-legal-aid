require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      uid: 'test-user',
      email: 'provider@example.com',
      office_codes: office_codes,
    }
  end

  let(:office_codes) { %w[A1 B2 C3] }

  describe '#display_name' do
    it { expect(subject.display_name).to eq('provider@example.com') }
  end

  describe '#multiple_offices?' do
    context 'provider has more than 1 office account' do
      it { expect(subject.multiple_offices?).to be(true) }
    end

    context 'provider has only 1 office account' do
      let(:office_codes) { %w[A1] }

      it { expect(subject.multiple_offices?).to be(false) }
    end
  end
end
