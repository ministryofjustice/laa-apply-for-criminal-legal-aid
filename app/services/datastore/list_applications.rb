module Datastore
  class ListApplications
    attr_reader :filtering, :sorting, :pagination

    def initialize(filtering:, sorting:, pagination:)
      @filtering = filtering
      @sorting = sorting
      @pagination = pagination
    end

    def call
      Rails.error.handle do
        result = DatastoreApi::Requests::ListApplications.new(
          **filtering, **sorting, **pagination
        ).call

        Kaminari.paginate_array(result, total_count: result.pagination['total_count'])
      end
    end
  end
end
