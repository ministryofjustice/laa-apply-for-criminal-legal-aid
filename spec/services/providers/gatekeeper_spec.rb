require 'rails_helper'

RSpec.describe Providers::Gatekeeper do
  subject { described_class.new(auth_info) }

  let(:auth_info) do
    double(
      email:,
      roles:,
      office_codes:,
    )
  end

  let(:email) { 'test@example.com' }
  let(:roles) { 'role1,role2' }
  let(:office_codes) { 'code1:code2' }

  describe '#access_allowed?' do
    context 'when there are office codes' do
      it 'allows the access' do
        expect(subject.access_allowed?).to be(true)
        expect(subject.reason).to be_nil
      end
    end

    context 'when there are no office codes' do
      let(:office_codes) { '' }

      it 'disallows the access' do
        expect(subject.access_allowed?).to be(false)
        expect(subject.reason).to be(:no_office_codes)
      end
    end
  end
end
