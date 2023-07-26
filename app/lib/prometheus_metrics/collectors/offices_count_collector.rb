module PrometheusMetrics
  module Collectors
    class OfficesCountCollector < BaseCollector
      def type
        'crime_apply_provider_offices_count'.freeze
      end

      def description
        'Number of offices'.freeze
      end

      def metrics
        [
          offices_count,
        ]
      end

      private

      def offices_count
        result = cache { Provider.pluck(:office_codes).flatten.uniq.count }
        observe_counter(result)
      end
    end
  end
end
