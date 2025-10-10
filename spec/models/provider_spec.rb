require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject(:provider) { described_class.new(attributes) }

  let(:attributes) do
    {
      uid: 'test-user',
      email: 'provider@example.com',
      office_codes: set_office_codes,
      selected_office_code: set_selected_office_code
    }
  end

  let(:set_office_codes) { %w[1K022G 2A555X 3B345C 4C567D] }
  let(:set_selected_office_code) { nil }

  it_behaves_like 'a reauthable model'

  describe '#display_name' do
    it { expect(provider.display_name).to eq('provider@example.com') }
  end

  describe '#multiple_offices?' do
    context 'when provider has more than 1 office account' do
      it { expect(provider.multiple_offices?).to be(true) }
    end

    context 'when provider has only 1 office account' do
      let(:set_office_codes) { %w[1K022G] }

      it { expect(provider.multiple_offices?).to be(false) }
    end
  end

  describe '#selected_office_code' do
    subject(:selected_office_code) { provider.selected_office_code }

    it { is_expected.to be_nil }

    context 'when selected office code is not a provider office code' do
      let(:set_selected_office_code) { '1A123B' }

      it { is_expected.to be_nil }
    end

    context 'when selected office code is active' do
      let(:set_selected_office_code) { '2A555X' }

      it { is_expected.to eq '2A555X' }
    end

    context 'when there is only one active office code' do
      let(:set_office_codes) { %w[1K022G] }

      it 'defaults to the active office code' do
        expect(selected_office_code).to eq('1K022G')
      end
    end
  end

  describe '#office_codes' do
    subject(:office_codes) { provider.office_codes }

    it { is_expected.to eq %w[1K022G 2A555X 3B345C 4C567D] }
  end
end
