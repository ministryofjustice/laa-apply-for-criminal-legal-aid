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

  let(:email) { nil }
  let(:roles) { 'EFORMS,EFORMS_eFormsAuthor,CRIMEAPPLY' }
  let(:office_codes) { nil }

  describe 'email attribute' do
    context 'when the email attribute is present' do
      let(:email) { 'test@example.com' }

      it 'returns the email' do
        expect(subject.info).to match(a_hash_including(email: 'test@example.com'))
      end
    end

    context 'when the email attribute is not present or blank' do
      let(:email) { nil }

      it 'returns a fallback mock email' do
        expect(subject.info).to match(a_hash_including(email: 'provider@example.com'))
      end
    end
  end

  describe 'roles attribute' do
    it 'returns an array of account roles' do
      expect(subject.info).to match(a_hash_including(roles: %w[EFORMS EFORMS_eFormsAuthor CRIMEAPPLY]))
    end
  end

  describe '#office_codes' do
    let(:codes_array) { %w[1A123B 2A555X] }

    context 'when codes are tokenized with commas' do
      let(:office_codes) { codes_array.join(',') }

      it 'returns the account description' do
        expect(subject.info).to match(a_hash_including(office_codes: codes_array))
      end
    end

    context 'when codes are tokenized with colons' do
      let(:office_codes) { codes_array.join(':') }

      it 'returns the account description' do
        expect(subject.info).to match(a_hash_including(office_codes: codes_array))
      end
    end
  end
end
