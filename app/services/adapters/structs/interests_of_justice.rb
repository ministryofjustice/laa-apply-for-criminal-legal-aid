module Adapters
  module Structs
    class InterestsOfJustice < BaseStructAdapter
      # [
      #   {
      #     "type": "loss_of_liberty",
      #     "reason": "More details about loss of liberty."
      #   },
      #   ...
      # ]
      #
      def initialize(collection)
        ioj = Ioj.new(types: collection.pluck(:type))

        ioj.attributes = {}.tap do |attrs|
          collection.each do |item|
            attrs.merge!(
              IojReasonType.new(item.type).justification_field_name => item.reason
            )
          end
        end

        # For re-hydration and summary page, we don't really want
        # a "blank" instance of the IoJ, so we `nil` in those cases
        ioj = nil if ioj.types.empty?

        super(ioj)
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            only: [:types] + IojReasonType.justification_attrs
          )
        )
      end
    end
  end
end
