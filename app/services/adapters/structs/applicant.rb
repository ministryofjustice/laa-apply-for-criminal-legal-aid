module Adapters
  module Structs
    class Applicant < BaseStructAdapter
      # For MVP this will always be `yes`
      # This is not part of the application JSON for now.
      def has_nino
        YesNoAnswer::YES
      end

      def home_address
        HomeAddress.new(super.attributes) if super
      end

      def correspondence_address
        CorrespondenceAddress.new(super.attributes) if super
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:has_nino]
          )
        )
      end
    end
  end
end
