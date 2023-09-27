require 'rails_helper'

RSpec.describe Providers::Gatekeeper do
  subject { described_class.new(auth_info) }

  let(:auth_info) do
    double(
      email:,
      office_codes:,
    )
  end

  let(:email) { 'test@example.com' }
  let(:office_codes) { %w[1A123B 2A555X] }

  describe '#provider_enrolled?' do
    before do
      allow(subject).to receive_messages(email_enrolled?: false, office_enrolled?: false)
    end

    it 'checks if the email is enrolled' do
      expect(subject).to receive(:email_enrolled?)
      subject.provider_enrolled?
    end

    it 'checks if any office codes are enrolled' do
      expect(subject).to receive(:office_enrolled?)
      subject.provider_enrolled?
    end
  end

  describe '#office_enrolled?' do
    context 'when any of the office codes are in the allow list' do
      it 'returns true' do
        expect(subject.office_enrolled?).to be(true)
      end
    end

    context 'when no office codes are in the allow list' do
      let(:office_codes) { %w[1X000X] }

      it 'returns false' do
        expect(subject.office_enrolled?).to be(false)
      end
    end
  end
end
