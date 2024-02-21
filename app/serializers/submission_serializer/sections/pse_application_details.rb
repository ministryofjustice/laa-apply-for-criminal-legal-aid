module SubmissionSerializer
  module Sections
    class PseApplicationDetails < Sections::BaseSection
      def to_builder # rubocop:disable Metrics/AbcSize
        Jbuilder.new do |json|
          json.id crime_application.id
          json.parent_id crime_application.parent_id
          json.schema_version 1.0
          json.reference crime_application.reference
          json.application_type crime_application.application_type
          json.created_at crime_application.created_at
          json.submitted_at crime_application.submitted_at
          json.additional_information crime_application.additional_information
        end
      end
    end
  end
end
