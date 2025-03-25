module Datastore
  class ArchiveApplication
    attr_reader :application_id

    def initialize(application_id)
      @application_id = application_id
    end

    def call
      datastore_response
    end

    private

    include DatastoreApi::Traits::ApiRequest

    def datastore_response
      http_client.put("/applications/#{application_id}/archive", {})
    end
  end
end
