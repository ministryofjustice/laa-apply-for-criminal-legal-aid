module Adapters
  module Structs
    class BaseStructAdapter < SimpleDelegator
      NIL_UUID = '00000000-0000-0000-0000-000000000000'.freeze

      def to_param
        NIL_UUID
      end
    end
  end
end
