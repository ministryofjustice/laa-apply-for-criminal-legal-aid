module Datastore
  class ApplicationCounters
    PER_PAGE_LIMIT = 1
    FALLBACK_COUNT = 0

    attr_reader :office_code

    def initialize(office_code:)
      @office_code = office_code
    end

    def returned_count
      @returned_count ||= count(ApplicationStatus::RETURNED)
    end

    private

    # Fallback to `zero`, but do not blow up.
    # As per locales, it will not show counter on the tab.
    def count(status)
      return 0 if office_code.blank?

      Rails.error.handle(fallback: -> { FALLBACK_COUNT }) do
        result = DatastoreApi::Requests::ListApplications.new(
          status: status.to_s, office_code: office_code, exclude_archived: true, per_page: PER_PAGE_LIMIT
        ).call

        result.pagination.fetch('total_count')
      end
    end
  end
end
