require 'rails_helper'

RSpec.describe LogContext, type: :model do
  subject { described_class.new(current_provider:, ip_address:, options:) }

  let(:current_provider) { instance_double(Provider, id: 1) }
  let(:ip_address) { '123.123.123' }
  let(:options) { {} }

  describe 'initialize' do
    let(:options) { { location: 'London' } }

    it 'is initialised with user information' do
      expect(subject.current_provider.id).to eq(1)
      expect(subject.ip_address).to eq('123.123.123')
    end

    it 'can take additional option arguments' do
      expect(subject.options).to eq(options: { location: 'London' })
    end
  end

  describe '#to_h' do
    it 'returns hash value of provided arguments' do
      expect(subject.to_h).to eq(
        provider_id: 1,
        provider_ip: '123.123.123',
        options: {}
      )
    end
  end

  describe '#<<' do
    it 'can add additional context options to hash' do
      subject << { location: 'London' }
      expect(subject.to_h).to eq(provider_id: 1, provider_ip: '123.123.123', options: {}, location: 'London')
    end

    it 'raises error if hash is not provided' do
      expect { subject << 123 }.to raise_error(ArgumentError)
    end
  end
end
