module SubmissionSerializer
  module Sections
    class CaseDetails < Sections::BaseSection
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def to_builder
        kase = crime_application.case

        Jbuilder.new do |json|
          json.case_details do
            json.urn kase.urn
            json.case_type kase.case_type
            json.appeal_maat_id kase.appeal_maat_id
            json.appeal_with_changes_maat_id kase.appeal_with_changes_maat_id
            json.appeal_with_changes_details kase.appeal_with_changes_details
            json.hearing_court_name kase.hearing_court_name
            json.hearing_date kase.hearing_date
            json.offences(kase.charges.map { |charge| Definitions::Offence.generate(charge) })

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
