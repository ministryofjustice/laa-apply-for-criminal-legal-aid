module PrometheusMetrics
  class ApplicationsCountCollector < PrometheusExporter::Server::TypeCollector
    #
    # Prometheus monitoring service on kubernetes will scrape
    # the `/metrics` endpoint frequently (every 15s), but these
    # custom metrics don't require such precision.
    # We cache (in-memory) for 5 minutes the results.
    #
    def expires_in
      5.minutes
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

    def total_count
      counter = counter(
        'crime_apply_total_applications_count',
        'Number of application records'
      )

      result = Rails.cache.fetch(__method__, expires_in:) { CrimeApplication.count }

      counter.observe(result)
      counter
    end

    def in_progress_count
      counter = counter(
        'crime_apply_in_progress_applications_count',
        'Number of in progress applications'
      )

      result = Rails.cache.fetch(__method__, expires_in:) { CrimeApplication.with_applicant.count }

      counter.observe(result)
      counter
    end

    def date_stamped_count
      counter = counter(
        'crime_apply_date_stamped_applications_count',
        'Number of date stamped applications'
      )

      result = Rails.cache.fetch(__method__, expires_in:) do
        CrimeApplication.where.not(date_stamp: nil).count
      end

      counter.observe(result)
      counter
    end

    def stale_count
      counter = counter(
        'crime_apply_stale_applications_count',
        'Number of stale applications (not updated for more than 1 week)'
      )

      result = Rails.cache.fetch(__method__, expires_in:) do
        CrimeApplication.with_applicant.where(['crime_applications.updated_at < ?', 1.week.ago]).count
      end

      counter.observe(result)
      counter
    end

    def counter(name, help)
      PrometheusExporter::Metric::Counter.new(name, help)
    end
  end
end
