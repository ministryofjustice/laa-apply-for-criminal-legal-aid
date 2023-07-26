module PrometheusMetrics
  module Collectors
    class BaseCollector < PrometheusExporter::Server::TypeCollector
      #
      # Prometheus monitoring service on kubernetes will scrape
      # the `/metrics` endpoint frequently (every 15s), but these
      # custom metrics don't require such precision.
      # We cache (in-memory) for a few minutes the results.
      #
      def expires_in
        5.minutes
      end

      # :nocov:
      def description
        raise 'implement in subclasses'
      end
      # :nocov:

      private

      def cache(&block)
        Rails.cache.fetch(
          "#{type}/#{caller_locations(1..1).first.base_label}", expires_in:, &block
        )
      end

      # We can have different types of metrics, but for now
      # we only need and use the `counter` type
      def counter
        PrometheusExporter::Metric::Counter.new(type, description)
      end

      def observe_counter(result, labels = {})
        gauge = counter
        gauge.observe(result, labels)
        gauge
      end
    end
  end
end
