module Datastore
  class ApplicationCounters
    PER_PAGE_LIMIT = 1
    FALLBACK_COUNT = 0

    def returned_count
      @returned_count ||= count(ApplicationStatus::RETURNED)
    end

    private

    def count(status)
      result = DatastoreApi::Requests::ListApplications.new(
        status: status.to_s, per_page: PER_PAGE_LIMIT
      ).call

      result.pagination.fetch('total_count')
    rescue StandardError => e
      Rails.logger.error(e)
      Sentry.capture_exception(e)

      # Fallback to `zero`, but do not blow up.
      # As per locales, it will not show counter on the tab.
      FALLBACK_COUNT
    end
  end
end
