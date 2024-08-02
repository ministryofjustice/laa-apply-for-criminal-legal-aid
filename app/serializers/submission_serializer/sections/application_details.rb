module SubmissionSerializer
  module Sections
    class ApplicationDetails < Sections::BaseSection
      def to_builder # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        Jbuilder.new do |json|
          json.id crime_application.id
          json.parent_id crime_application.parent_id
          json.schema_version 1.0
          json.reference crime_application.reference
          json.application_type crime_application.application_type
          json.created_at crime_application.created_at
          json.submitted_at crime_application.submitted_at
          json.date_stamp crime_application.date_stamp || crime_application.submitted_at
          json.is_means_tested crime_application.is_means_tested
          json.ioj_passport crime_application.ioj_passport
          json.means_passport(
            applicant.present? ? Passporting::MeansPassporter.new(crime_application).means_passport : []
          )
          json.additional_information crime_application.additional_information
          json.pre_cifc_reference_number crime_application.pre_cifc_reference_number
          json.pre_cifc_maat_id crime_application.pre_cifc_maat_id
          json.pre_cifc_usn crime_application.pre_cifc_usn
        end
      end
    end
  end
end
