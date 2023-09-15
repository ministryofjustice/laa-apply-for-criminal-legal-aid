require 'rails_helper'

# Very light-touch smoke test as there is no point in having these
# too elaborated, as metrics will probably change frequently
#
describe PrometheusMetrics::Collectors::OfficesCountCollector do
  subject { described_class.new }

  let(:expires_in) { 5.minutes }
  let(:type) { 'crime_apply_provider_offices_count' }
  let(:description) { 'Number of offices' }

  describe '#type' do
    it { expect(subject.type).to eq(type) }
  end

  describe '#description' do
    it { expect(subject.description).to eq(description) }
  end

  describe '#expires_in' do
    it { expect(subject.expires_in).to eq(expires_in) }
  end

  describe '#metrics' do
    before do
      allow(Provider).to receive(:pluck).with(:office_codes).and_return([%w[a b], %w[a c], %w[x]])
    end

    it 'calls the expected methods to gather metrics' do
      expect(
        subject.metrics.map(&:data)
      ).to contain_exactly(
        { {} => 4 },
      )
    end

    it 'uses Rails cache' do
      expect(
        Rails.cache
      ).to receive(:fetch).with("#{type}/offices_count", expires_in:).and_return(10)

      # testing just one, all counters behave the same
      subject.send(:offices_count)
    end
  end
end
