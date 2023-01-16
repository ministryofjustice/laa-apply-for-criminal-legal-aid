module Adapters
  module Structs
    class BaseStructAdapter < SimpleDelegator
      include ActiveModel::Serialization

      NIL_UUID = '00000000-0000-0000-0000-000000000000'.freeze

      def to_param
        NIL_UUID
      end

      # Used by `serializable_hash`
      # For consistency we want all attribute keys as strings
      def attributes
        __getobj__ ? super.stringify_keys : {}
      end
    end
  end
end
