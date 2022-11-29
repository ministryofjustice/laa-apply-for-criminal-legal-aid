module SubmissionSerializer
  module Sections
    class ApplicationDetails < Sections::BaseSection
      # rubocop:disable Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          json.id crime_application.id
          json.schema_version 1.0
          json.reference crime_application.reference
          json.created_at crime_application.created_at
          json.submitted_at crime_application.submitted_at
          json.date_stamp crime_application.date_stamp
          json.status crime_application.status
          json.ioj_passport crime_application.ioj_passport
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
