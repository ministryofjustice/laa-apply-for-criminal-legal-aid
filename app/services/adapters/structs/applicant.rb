module Adapters
  module Structs
    class Applicant < BaseStructAdapter
      def home_address
        HomeAddress.new(super.attributes) if super
      end

      def correspondence_address
        CorrespondenceAddress.new(super.attributes) if super
      end

      attr_accessor :passporting_benefit

      def has_nino
        nino.present? ? 'yes' : 'no'
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:has_nino, :passporting_benefit],
          )
        )
      end
    end
  end
end
