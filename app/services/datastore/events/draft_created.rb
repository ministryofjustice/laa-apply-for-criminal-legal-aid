module Datastore
  module Events
    class DraftCreated
      attr_reader :entity_id, :entity_type, :business_reference

      def initialize(entity_id:, entity_type:, business_reference:)
        @entity_id = entity_id
        @entity_type = entity_type
        @business_reference = business_reference
      end

      def call
        datastore_response
      end

      private

      include DatastoreApi::Traits::ApiRequest

      def datastore_response
        http_client.post('/applications/draft_created', { entity_id:, entity_type:, business_reference: })
      end
    end
  end
end
