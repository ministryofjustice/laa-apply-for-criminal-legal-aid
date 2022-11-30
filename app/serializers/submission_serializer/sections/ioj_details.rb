module SubmissionSerializer
  module Sections
    class IojDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.interests_of_justice do
            if crime_application.ioj.present?
              serialize_types(json)
            else
              json.merge!([])
            end
          end
        end
      end

      private

      def serialize_types(json)
        crime_application.ioj.types.each do |ioj_type|
          json.child! do
            type = IojReasonType.new(ioj_type)

            json.type type.to_s
            json.reason crime_application.ioj[type.justification_field_name]
          end
        end
      end
    end
  end
end
