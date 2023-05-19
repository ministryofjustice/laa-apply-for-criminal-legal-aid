require 'rails_helper'

RSpec.describe Providers::AuthAdapter do
  subject { described_class.call(auth_hash) }

  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      info: {
        email:,
        roles:,
        office_codes:,
      }
    )
  end

  let(:email) { 'test@example.com' }
  let(:roles) { 'EFORMS,EFORMS_eFormsAuthor,CRIMEAPPLY' }
  let(:office_codes) { '1A123B:2A555X' }

  describe 'email attribute' do
    it 'returns the email' do
      expect(subject.info).to match(a_hash_including(email: 'test@example.com'))
    end
  end

  describe 'roles attribute' do
    it 'returns an array of account roles' do
      expect(subject.info).to match(a_hash_including(roles: %w[EFORMS EFORMS_eFormsAuthor CRIMEAPPLY]))
    end
  end

  describe '#office_codes' do
    it 'returns the account description' do
      expect(subject.info).to match(a_hash_including(office_codes: %w[1A123B 2A555X]))
    end
  end
end
