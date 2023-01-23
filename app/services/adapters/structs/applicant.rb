module Adapters
  module Structs
    class Applicant < BaseStructAdapter
      # NOTE: for MVP this is always true, as we are doing
      # screening of applicants with DWP. This will change
      # post-MVP but we don't know yet how exactly.
      def passporting_benefit
        true
      end

      # Same as above, for MVP will always be `yes`
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
            methods: [:has_nino, :passporting_benefit]
          )
        )
      end
    end
  end
end
