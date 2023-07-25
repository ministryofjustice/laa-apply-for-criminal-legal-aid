module PrometheusMetrics
  class ApplicationsCountCollector < PrometheusExporter::Server::TypeCollector
    #
    # Prometheus monitoring service on kubernetes will scrape
    # the `/metrics` endpoint frequently (every 15s), but these
    # custom metrics don't require such precision.
    # We cache (in-memory) for a few minutes the results.
    #
    def expires_in
      2.minutes
    end

    def type
      'crime_applications'.freeze
    end

    def metrics
      [
        total_count,
        in_progress_count,
        date_stamped_count,
        stale_count,
      ]
    end

    private

    def counter
      PrometheusExporter::Metric::Counter.new(
        'crime_apply_applications_count', 'Number of applications by status'
      )
    end

    def total_count
      result = Rails.cache.fetch(__method__, expires_in:) { CrimeApplication.count }

      gauge = counter
      gauge.observe(result, status: 'started')
      gauge
    end

    def in_progress_count
      result = Rails.cache.fetch(__method__, expires_in:) { CrimeApplication.with_applicant.count }

      gauge = counter
      gauge.observe(result, status: 'in_progress')
      gauge
    end

    def date_stamped_count
      result = Rails.cache.fetch(__method__, expires_in:) do
        CrimeApplication.where.not(date_stamp: nil).count
      end

      gauge = counter
      gauge.observe(result, status: 'date_stamped')
      gauge
    end

    def stale_count
      result = Rails.cache.fetch(__method__, expires_in:) do
        CrimeApplication.with_applicant.where(['crime_applications.updated_at < ?', 1.week.ago]).count
      end

      gauge = counter
      gauge.observe(result, status: 'stale')
      gauge
    end
  end
end
