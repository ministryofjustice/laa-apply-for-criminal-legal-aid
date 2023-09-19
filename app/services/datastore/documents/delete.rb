module Datastore
  module Documents
    class Delete
      attr_reader :errors

      def initialize(object_key:)
        @object_key = object_key
        @errors = []
      end

      def call
        response = DatastoreApi::Requests::Documents::Delete.new(object_key: @object_key).call
        response == { 'object_key' => @object_key.to_s }
      rescue StandardError => e
        errors << e
        false
      end
    end
  end
end
