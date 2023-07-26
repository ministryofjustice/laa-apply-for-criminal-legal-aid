module PrometheusMetrics
  module Collectors
    class ApplicationsCountCollector < BaseCollector
      def type
        'crime_apply_applications_count'.freeze
      end

      def description
        'Number of applications by status'.freeze
      end

      def metrics
        [
          total_count,
          in_progress_count,
          date_stamped_count,
          stale_count,
        ]
      end

      # Some applications can be submitted very fast, so we reduce
      # the cache from the default 5m to 2m in this collector
      def expires_in
        2.minutes
      end

      private

      def total_count
        result = cache { CrimeApplication.count }
        observe_counter(result, status: 'started')
      end

      def in_progress_count
        result = cache { CrimeApplication.with_applicant.count }
        observe_counter(result, status: 'in_progress')
      end

      def date_stamped_count
        result = cache { CrimeApplication.where.not(date_stamp: nil).count }
        observe_counter(result, status: 'date_stamped')
      end

      def stale_count
        result = cache do
          CrimeApplication.with_applicant.where(['crime_applications.updated_at < ?', 1.week.ago]).count
        end

        observe_counter(result, status: 'stale')
      end
    end
  end
end
