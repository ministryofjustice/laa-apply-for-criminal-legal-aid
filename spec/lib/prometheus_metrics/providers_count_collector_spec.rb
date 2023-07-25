require 'rails_helper'

# Very light-touch smoke test as there is no point in having these
# too elaborated, as metrics will probably change frequently
#
describe PrometheusMetrics::ProvidersCountCollector do
  subject { described_class.new }

  let(:expires_in) { 5.minutes }
  let(:type) { 'providers' }

  describe '#expires_in' do
    it { expect(subject.expires_in).to eq(expires_in) }
  end

  describe '#type' do
    it { expect(subject.type).to eq(type) }
  end

  describe '#metrics' do
    before do
      # rubocop:disable RSpec/MessageChain
      allow(Provider).to receive(:count).and_return(10)
      allow(Provider).to receive_message_chain(:where, :count).and_return(5, 2, 1)
      # rubocop:enable RSpec/MessageChain
    end

    it 'calls the expected methods to gather metrics' do
      expect(
        subject.metrics.map(&:data)
      ).to contain_exactly(
        { { status: 'enrolled' } => 10 },
        { { status: 'multi_office' } => 5 },
        { { status: 'disengaged' } => 2 },
        { { status: 'idle' } => 1 },
      )
    end

    it 'uses Rails cache' do
      expect(
        Rails.cache
      ).to receive(:fetch).with(:enrolled_count, expires_in:).and_return(10)

      # testing just one, all counters behave the same
      subject.send(:enrolled_count)
    end
  end
end
