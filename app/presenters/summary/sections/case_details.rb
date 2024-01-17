module Summary
  module Sections
    class CaseDetails < Sections::BaseSection
      def show?
        kase.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
          Components::ValueAnswer.new(
            :case_type, kase.case_type,
            change_path: edit_steps_client_case_type_path
          ),

          Components::DateAnswer.new(
            :appeal_lodged_date, kase.appeal_lodged_date,
            change_path: edit_steps_client_appeal_details_path
          ),

          Components::FreeTextAnswer.new(
            :appeal_with_changes_details, kase.appeal_with_changes_details,
            change_path: edit_steps_client_appeal_details_path
          ),

          # This is an optional field, depending on case type
          # If it is an empty string (not nil), it will show as `None`
          Components::FreeTextAnswer.new(
            :previous_maat_id, kase.appeal_maat_id,
            show: !kase.appeal_maat_id.nil?,
            change_path: edit_steps_client_appeal_details_path
          ),

          Components::FreeTextAnswer.new(
            :case_urn, kase.urn,
            change_path: edit_steps_case_urn_path, show: true
          ),

          Components::FreeTextAnswer.new(
            :has_case_concluded, kase.has_case_concluded,
            change_path: edit_steps_case_has_case_concluded_path, show: true
          ),

          Components::DateAnswer.new(
            :date_case_concluded, kase.date_case_concluded,
            change_path: edit_steps_case_has_case_concluded_path, show: kase.has_case_concluded.nil?
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def kase
        @kase ||= crime_application.case
      end
    end
  end
end
