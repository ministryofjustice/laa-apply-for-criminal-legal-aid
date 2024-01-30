module SubmissionSerializer
  module Sections
    class CaseDetails < Sections::BaseSection
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          json.case_details do
            json.urn kase.urn
            json.case_type kase.case_type
            json.has_case_concluded kase.has_case_concluded
            json.date_case_concluded kase.date_case_concluded
            json.is_client_remanded kase.is_client_remanded
            json.date_client_remanded kase.date_client_remanded
            json.is_preorder_work_claimed kase.is_preorder_work_claimed
            json.preorder_work_date kase.preorder_work_date
            json.preorder_work_details kase.preorder_work_details
            json.appeal_maat_id kase.appeal_maat_id
            json.appeal_lodged_date kase.appeal_lodged_date
            json.appeal_with_changes_details kase.appeal_with_changes_details

            json.hearing_court_name kase.hearing_court_name
            json.hearing_date kase.hearing_date
            json.is_first_court_hearing kase.is_first_court_hearing
            json.first_court_hearing_name kase.first_court_hearing_name

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
