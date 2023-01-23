module Adapters
  module Structs
    class BaseStructAdapter < SimpleDelegator
      include ActiveModel::Serialization

      # Used by `serializable_hash`
      # For consistency we want all attribute keys as strings
      def attributes
        __getobj__ ? super.stringify_keys : {}
      end
    end
  end
end
