module Datastore
  class GetApplications
    attr_reader :filtering, :sorting, :pagination

    def initialize(filtering:, sorting:, pagination:)
      @filtering = filtering
      @sorting = sorting
      @pagination = pagination
    end

    def call
      result = DatastoreApi::Requests::ListApplications.new(
        **filtering, **sorting, **pagination
      ).call

      Kaminari.paginate_array(result, total_count: result.pagination['total_count'])
    rescue StandardError => e
      Rails.logger.error(e)
      Sentry.capture_exception(e)

      nil
    end
  end
end
