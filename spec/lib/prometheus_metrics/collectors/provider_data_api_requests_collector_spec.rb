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
      ).to contain_exactly(success_metric, failure_metric)
    end
  end
end
