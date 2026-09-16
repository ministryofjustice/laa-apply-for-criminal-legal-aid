require 'rails_helper'

RSpec.describe ProviderDataApi::RequestMonitor do
  let(:operation) { described_class::OPERATION_GET_OFFICE_SCHEDULES }

  before { described_class.reset! }

  it 'has no activity before any requests' do
    expect(described_class.activity_snapshot).to be_empty
  end

  it 'records the first failure without requiring a previous successful request' do
    travel_to(Time.zone.at(1_800_000_000)) do
      described_class.record_failure(operation: operation, exception: Faraday::ConnectionFailed.new('offline'))
      expect(described_class.activity_snapshot).to eq(
        { outcome: 'failure', operation: operation } => 1_800_000_000.0
      )
    end
  end

  it 'updates the latest timestamp independently for each outcome' do
    travel_to(Time.zone.at(1_800_000_000)) do
      described_class.record_failure(operation: operation, exception: Faraday::ConnectionFailed.new('offline'))
    end
    travel_to(Time.zone.at(1_800_000_060)) do
      described_class.record_success(operation: operation, status: 200)
      described_class.record_not_found(operation: operation, status: 204)
      described_class.record_failure(operation: operation, exception: Faraday::ConnectionFailed.new('offline'))
    end
    expect(described_class.activity_snapshot).to eq(
      { outcome: 'failure', operation: operation } => 1_800_000_060.0,
      { outcome: 'success', operation: operation } => 1_800_000_060.0,
      { outcome: 'not_found', operation: operation } => 1_800_000_060.0
    )
  end
end
