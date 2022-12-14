module Datastore
  class GetApplications
    def initialize(status: nil, page: nil, per_page: nil, sort: nil)
      @status = status
      @page = page
      @per_page = per_page
      @sort = sort
    end

    def call
      result = DatastoreApi::Requests::ListApplications.new(
        status: status_filter,
        page: @page,
        per_page: @per_page,
        sort: @sort
      ).call

      Kaminari.paginate_array(result, total_count: result.pagination['total_count'])
    rescue StandardError => e
      Rails.logger.error(e)
      Sentry.capture_exception(e)

      nil
    end

    private

    def status_filter
      allowed_statuses = [
        ApplicationStatus::SUBMITTED, ApplicationStatus::RETURNED
      ].map(&:to_s)

      allowed_statuses.include?(@status) ? @status : allowed_statuses.first
    end
  end
end
