module SubmissionSerializer
  module Sections
    class CaseDetails < Sections::BaseSection
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          json.case_details do
            json.urn kase.urn
            json.case_type kase.case_type
            json.appeal_maat_id kase.appeal_maat_id
            json.appeal_with_changes_maat_id nil # TODO: to be removed in schemas/fixtures
            json.appeal_lodged_date kase.appeal_lodged_date
            json.appeal_with_changes_details kase.appeal_with_changes_details
            json.hearing_court_name kase.hearing_court_name
            json.hearing_date kase.hearing_date

            json.offences Definitions::Offence.generate(kase.charges.complete)
            json.codefendants Definitions::Codefendant.generate(kase.codefendants)
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end

      private

      def kase
        @kase ||= crime_application.case
      end
    end
  end
end
