module Adapters
  module Structs
    class InterestsOfJustice < BaseStructAdapter
      def initialize(collection)
        super(collection)

        collection.each do |item|
          ioj = IojReasonType.new(item.type)

          instance_variable_set(
            :"@#{ioj.justification_field_name}", item.reason
          )
        end
      end

      def types
        pluck(:type)
      end

      def [](attr_name)
        instance_variable_get("@#{attr_name}".to_sym)
      end
    end
  end
end
