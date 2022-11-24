module SubmissionSerializer
  module Sections
    class ApplicationDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.id crime_application.id
          json.schema_version 1.0
          json.reference crime_application.reference
          json.created_at crime_application.created_at
          json.submitted_at crime_application.submitted_at
        end
      end
    end
  end
end
