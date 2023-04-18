module Adapters
  module Structs
    class Applicant < BaseStructAdapter
      def home_address
        HomeAddress.new(super.attributes) if super
      end

      def correspondence_address
        CorrespondenceAddress.new(super.attributes) if super
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: []
          )
        )
      end
    end
  end
end
