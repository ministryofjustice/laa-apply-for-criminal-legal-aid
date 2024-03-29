require 'rails_helper'

# Very light-touch smoke test as there is no point in having these
# too elaborated, as metrics will probably change frequently
#
describe PrometheusMetrics::Collectors::ApplicationsCountCollector do
  subject { described_class.new }

  let(:expires_in) { 2.minutes }
  let(:type) { 'crime_apply_applications_count' }
  let(:description) { 'Number of applications by status' }

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
      # rubocop:disable RSpec/MessageChain
      allow(CrimeApplication).to receive(:count).and_return(10)
      allow(CrimeApplication).to receive_message_chain(:with_applicant, :count).and_return(8)
      allow(CrimeApplication).to receive_message_chain(:where, :not, :count).and_return(5)
      allow(CrimeApplication).to receive_message_chain(:with_applicant, :where, :count).and_return(2)
      # rubocop:enable RSpec/MessageChain
    end

    it 'calls the expected methods to gather metrics' do
      expect(
        subject.metrics.map(&:data)
      ).to contain_exactly(
        { { status: 'started' } => 10 },
        { { status: 'in_progress' } => 8 },
        { { status: 'date_stamped' } => 5 },
        { { status: 'stale' } => 2 },
      )
    end

    it 'uses Rails cache' do
      expect(
        Rails.cache
      ).to receive(:fetch).with("#{type}/total_count", expires_in:).and_return(10)

      # testing just one, all counters behave the same
      subject.send(:total_count)
    end
  end
end
