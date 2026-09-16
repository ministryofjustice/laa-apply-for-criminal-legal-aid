require 'rails_helper'

describe PrometheusMetrics::Collectors::ProviderDataApiRequestsCollector do
  subject { described_class.new }

  let(:type) { 'provider_data_api_requests_total' }
  let(:description) { 'Total Provider Data API requests by outcome' }
  let(:operation) { ProviderDataApi::RequestMonitor::OPERATION_GET_OFFICE_SCHEDULES }

  before do
    ProviderDataApi::RequestMonitor.reset!
  end

  describe '#type' do
    it { expect(subject.type).to eq(type) }
  end

  describe '#description' do
    it { expect(subject.description).to eq(description) }
  end

  describe '#metrics' do
    let(:success_metric) do
      {
        {
          outcome: 'success',
          operation: operation,
          http_status: '200',
          error_class: 'none',
        } => 1
      }
    end
    let(:failure_metric) do
      {
        {
          outcome: 'failure',
          operation: operation,
          http_status: 'none',
          error_class: 'Faraday::ConnectionFailed',
        } => 1
      }
    end

    before do
      allow(Time).to receive(:now).and_return(Time.zone.at(1_800_000_000))
      ProviderDataApi::RequestMonitor.record_success(
        operation: operation,
        status: 200
      )
      ProviderDataApi::RequestMonitor.record_failure(
        operation: operation,
        exception: Faraday::ConnectionFailed.new('timeout')
      )
    end

    it 'returns counters grouped by labels' do
      expect(
        subject.metrics.map(&:data)
      ).to contain_exactly(
        success_metric.merge(failure_metric),
        {
          { outcome: 'success', operation: operation } => 1_800_000_000.0,
          { outcome: 'failure', operation: operation } => 1_800_000_000.0
        }
      )
    end

    it 'emits each metric family once so mixed outcomes can be scraped' do
      text = subject.metrics.map(&:to_prometheus_text).join("\n")
      expect(text.lines.grep(/^# HELP/).size).to eq(2)
      expect(subject.metrics.map(&:name)).to contain_exactly(
        type, 'provider_data_api_last_request_timestamp_seconds'
      )
    end

    it 'clears counters and timestamps on reset' do
      ProviderDataApi::RequestMonitor.reset!
      expect(subject.metrics).to be_empty
    end
  end
end
