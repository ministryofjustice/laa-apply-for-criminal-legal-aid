module PrometheusMetrics
  module Collectors
    class ProvidersCountCollector < BaseCollector
      def type
        'crime_apply_providers_count'.freeze
      end

      def description
        'Number of providers by status'.freeze
      end

      def metrics
        [
          enrolled_count,
          multi_office_count,
          disengaged_count,
          idle_count,
        ]
      end

      private

      def enrolled_count
        result = cache { Provider.count }
        observe_counter(result, status: 'enrolled')
      end

      def multi_office_count
        result = cache { Provider.where('array_length(office_codes, 1) > ?', 1).count }
        observe_counter(result, status: 'multi_office')
      end

      def disengaged_count
        result = cache { Provider.where("(settings ->> 'legal_rep_first_name') is null").count }
        observe_counter(result, status: 'disengaged')
      end

      def idle_count
        result = cache { Provider.where(current_sign_in_at: ...1.week.ago).count }
        observe_counter(result, status: 'idle')
      end
    end
  end
end
