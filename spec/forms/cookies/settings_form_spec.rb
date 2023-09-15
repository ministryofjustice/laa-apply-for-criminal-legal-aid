require 'rails_helper'

RSpec.describe Cookies::SettingsForm do
  subject { described_class.new(consent: consent_value, cookies: cookies_double) }

  let(:cookies_double) { {} }

  describe '.build' do
    it 'initialises the form object with the existing cookie value' do
      expect(described_class).to receive(:new).with(consent: 'foobar')
      described_class.build('foobar')
    end
  end

  describe '#save' do
    let(:default_cfg) { { expires: 6.months, httponly: true } }

    context 'for an `accept` value' do
      let(:consent_value) { described_class::CONSENT_ACCEPT }

      it 'sets the cookie and return the consent value' do
        expect(subject.save).to eq('accept')
        expect(cookies_double['crime_apply_cookies_consent']).to eq(default_cfg.merge(value: 'accept'))
      end
    end

    context 'for a `reject` value' do
      let(:consent_value) { described_class::CONSENT_REJECT }

      it 'sets the cookie and return the consent value' do
        expect(subject.save).to eq('reject')
        expect(cookies_double['crime_apply_cookies_consent']).to eq(default_cfg.merge(value: 'reject'))
      end
    end

    context 'for an unknown value' do
      let(:consent_value) { 'foobar' }

      it 'sets the cookie and defaults to `reject` consent' do
        expect(subject.save).to eq('reject')
        expect(cookies_double['crime_apply_cookies_consent']).to eq(default_cfg.merge(value: 'reject'))
      end
    end

    context 'for a nil value' do
      let(:consent_value) { nil }

      it 'sets the cookie and defaults to `reject` consent' do
        expect(subject.save).to eq('reject')
        expect(cookies_double['crime_apply_cookies_consent']).to eq(default_cfg.merge(value: 'reject'))
      end
    end
  end
end
