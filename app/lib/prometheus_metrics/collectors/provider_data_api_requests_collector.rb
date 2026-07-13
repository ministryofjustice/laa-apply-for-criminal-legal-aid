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
        ProviderDataApi::RequestMonitor.snapshot.map do |labels, count|
          observe_counter(count, labels)
        end
      end
    end
  end
end
