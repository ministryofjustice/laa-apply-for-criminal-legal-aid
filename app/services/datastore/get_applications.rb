module Datastore
  class GetApplications
    attr_reader :status, :office_code, :pagination

    def initialize(status:, office_code:, **pagination)
      @status = status
      @office_code = office_code
      @pagination = pagination
    end

    def call
      result = DatastoreApi::Requests::ListApplications.new(
        status:, office_code:, **pagination
      ).call

      Kaminari.paginate_array(result, total_count: result.pagination['total_count'])
    rescue StandardError => e
      Rails.logger.error(e)
      Sentry.capture_exception(e)

      nil
    end
  end
end
