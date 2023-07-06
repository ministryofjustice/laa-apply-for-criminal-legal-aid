module Datastore
  class GetApplication
    attr_reader :application_id

    def initialize(application_id)
      @application_id = application_id
    end

    def call
      app = Rails.error.record do
        # Will report and re-raise the exception
        DatastoreApi::Requests::GetApplication.new(application_id:).call
      end

      raise DatastoreApi::Errors::NotFoundError if superseded?(app)

      app
    rescue DatastoreApi::Errors::ApiError
      raise Errors::ApplicationNotFound
    end

    private

    def superseded?(app)
      ApplicationStatus.new(app.status).superseded?
    end
  end
end
