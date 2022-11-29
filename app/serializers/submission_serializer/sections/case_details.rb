module SubmissionSerializer
  module Sections
    class CaseDetails < Sections::BaseSection
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          json.case_details do
            json.urn crime_application.case.urn
            json.case_type crime_application.case.case_type
            json.appeal_maat_id crime_application.case.appeal_maat_id
            json.appeal_with_changes_maat_id crime_application.case.appeal_with_changes_maat_id
            json.appeal_with_changes_details crime_application.case.appeal_with_changes_details
            json.hearing_court_name crime_application.case.hearing_court_name
            json.hearing_date crime_application.case.hearing_date
            json.offences(crime_application.case.charges.map { |charge| Definitions::Offence.generate(charge) })

            json.codefendants(
              crime_application.codefendants.map do |codefendant|
                Definitions::Codefendant.generate(codefendant)
              end
            )
          end
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
