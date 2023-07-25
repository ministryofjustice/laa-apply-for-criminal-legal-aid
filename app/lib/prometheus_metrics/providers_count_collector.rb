module PrometheusMetrics
  class ProvidersCountCollector < PrometheusExporter::Server::TypeCollector
    #
    # Prometheus monitoring service on kubernetes will scrape
    # the `/metrics` endpoint frequently (every 15s), but these
    # custom metrics don't require such precision.
    # We cache (in-memory) for a few minutes the results.
    #
    def expires_in
      5.minutes
    end

    def type
      'providers'.freeze
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

    def counter
      PrometheusExporter::Metric::Counter.new(
        'crime_apply_providers_count', 'Number of providers by status'
      )
    end

    def enrolled_count
      result = Rails.cache.fetch(__method__, expires_in:) { Provider.count }

      gauge = counter
      gauge.observe(result, status: 'enrolled')
      gauge
    end

    def multi_office_count
      result = Rails.cache.fetch(__method__, expires_in:) do
        Provider.where('array_length(office_codes, 1) > ?', 1).count
      end

      gauge = counter
      gauge.observe(result, status: 'multi_office')
      gauge
    end

    def disengaged_count
      result = Rails.cache.fetch(__method__, expires_in:) do
        Provider.where("(settings ->> 'legal_rep_first_name') is null").count
      end

      gauge = counter
      gauge.observe(result, status: 'disengaged')
      gauge
    end

    def idle_count
      result = Rails.cache.fetch(__method__, expires_in:) do
        Provider.where(['current_sign_in_at < ?', 1.week.ago]).count
      end

      gauge = counter
      gauge.observe(result, status: 'idle')
      gauge
    end
  end
end
