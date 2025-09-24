module Datastore
  module Events
    class DraftDeleted
      attr_reader :entity_id, :entity_type, :business_reference, :reason, :deleted_by

      def initialize(entity_id:, entity_type:, business_reference:, reason:, deleted_by:)
        @entity_id = entity_id
        @entity_type = entity_type
        @business_reference = business_reference
        @reason = reason
        @deleted_by = deleted_by
      end

      def call
        datastore_response
      end

      private

      include DatastoreApi::Traits::ApiRequest

      def datastore_response
        http_client.post('/applications/draft_deleted',
                         { entity_id:, entity_type:, business_reference:, reason:, deleted_by: })
      end
    end
  end
end
