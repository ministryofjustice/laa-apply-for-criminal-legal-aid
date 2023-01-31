module Datastore
  class GetApplication
    attr_reader :application_id

    def initialize(application_id)
      @application_id = application_id
    end

    def call
      app = DatastoreApi::Requests::GetApplication.new(
        application_id:
      ).call

      raise DatastoreApi::Errors::NotFoundError if superseded?(app)

      app
    rescue DatastoreApi::Errors::NotFoundError
      raise Errors::ApplicationNotFound
    end

    private

    def superseded?(app)
      ApplicationStatus.new(app.fetch('status')).superseded?
    end
  end
end
