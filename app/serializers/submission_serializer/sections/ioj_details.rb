module SubmissionSerializer
  module Sections
    class IojDetails < Sections::BaseSection
      # rubocop:disable Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          json.interests_of_justice do
            crime_application.ioj.types.map.each do |ioj_type|
              json.child! do
                type = IojReasonType.new(ioj_type)

                json.type type.value.to_s
                json.reason crime_application.ioj[type.justification_field_name]
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
