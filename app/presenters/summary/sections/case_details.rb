module Summary
  module Sections
    class CaseDetails < Sections::BaseSection
      def name
        :case_details
      end

      def show?
        kase.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
          Components::FreeTextAnswer.new(
            :case_urn, kase.urn,
            change_path: edit_steps_case_urn_path, show: true
          ),

          Components::ValueAnswer.new(
            :case_type, kase.case_type,
            change_path: edit_steps_case_case_type_path
          ),

          Components::FreeTextAnswer.new(
            :previous_maat_id, kase.appeal_maat_id,
            change_path: edit_steps_case_case_type_path
          ),

          Components::FreeTextAnswer.new(
            :previous_maat_id, kase.appeal_with_changes_maat_id,
            change_path: edit_steps_case_case_type_path
          ),

          Components::FreeTextAnswer.new(
            :appeal_with_changes_details, kase.appeal_with_changes_details,
            change_path: edit_steps_case_case_type_path
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
