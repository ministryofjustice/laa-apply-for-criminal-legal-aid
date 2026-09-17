module PrometheusMetrics
  module Collectors
    class ProviderDataApiRequestsCollector < BaseCollector
      def type
        'provider_data_api_requests_total'.freeze
      end

      def description
        'Total Provider Data API requests by outcome'.freeze
      end

      def metrics
        request_metrics + activity_metrics
      end

      private

      def request_metrics
        snapshot = ProviderDataApi::RequestMonitor.snapshot
        return [] if snapshot.empty?

        metric = counter
        snapshot.each { |labels, count| metric.observe(count, labels) }
        [metric]
      end

      # Unlike increase(counter), timestamps also detect the first request after
      # startup, even if Prometheus never scraped a zero-valued counter.
      def activity_metrics
        snapshot = ProviderDataApi::RequestMonitor.activity_snapshot
        return [] if snapshot.empty?

        metric = PrometheusExporter::Metric::Gauge.new(
          'provider_data_api_last_request_timestamp_seconds',
          'Unix timestamp of the last Provider Data API request by outcome'
        )
        snapshot.each { |labels, timestamp| metric.observe(timestamp, labels) }
        [metric]
      end
    end
  end
end
