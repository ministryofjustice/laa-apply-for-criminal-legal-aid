module SubmissionSerializer
  module Sections
    class CaseDetails < Sections::BaseSection
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          next unless kase

          json.case_details do
            json.urn kase.urn
            json.case_type case_type
            json.has_case_concluded kase.has_case_concluded
            json.date_case_concluded kase.date_case_concluded
            json.is_preorder_work_claimed kase.is_preorder_work_claimed
            json.preorder_work_date kase.preorder_work_date
            json.preorder_work_details kase.preorder_work_details
            json.is_client_remanded kase.is_client_remanded
            json.date_client_remanded kase.date_client_remanded
            json.appeal_lodged_date kase.appeal_lodged_date
            json.appeal_original_app_submitted kase.appeal_original_app_submitted
            json.appeal_financial_circumstances_changed kase.appeal_financial_circumstances_changed
            json.appeal_with_changes_details kase.appeal_with_changes_details
            json.appeal_maat_id kase.appeal_maat_id
            json.appeal_usn kase.appeal_usn
            json.appeal_reference_number kase.appeal_reference_number
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

      def case_type
        if appeal_to_crown_court_case? && financial_circumstances_changed?
          return CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s
        end

        kase.case_type
      end

      def appeal_to_crown_court_case?
        kase.case_type == CaseType::APPEAL_TO_CROWN_COURT.to_s
      end

      def financial_circumstances_changed?
        kase.appeal_financial_circumstances_changed == YesNoAnswer::YES.to_s
      end
    end
  end
end
