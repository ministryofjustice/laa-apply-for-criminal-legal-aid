module SubmissionSerializer
  module Sections
    class IojDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.interests_of_justice do
            json.merge! serialized_ioj_types
          end
        end
      end

      private

      def serialized_ioj_types
        # IoJ record may be `nil` if any IoJ passport triggered
        ioj_types = ioj&.types || []

        ioj_types.map do |ioj_type|
          type = IojReasonType.new(ioj_type)
          reason = ioj[type.justification_field_name]

          { type: type.to_s, reason: reason }.as_json
        end
      end

      def ioj
        @ioj ||= crime_application.ioj
      end
    end
  end
end
