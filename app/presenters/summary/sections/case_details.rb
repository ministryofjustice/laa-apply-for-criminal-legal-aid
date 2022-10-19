module Summary
  module Sections
    class CaseDetails < Sections::BaseSection
      def name
        :case_details
      end

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
        ].select(&:show?)
      end

      private

      def kase
        @kase ||= crime_application.case
      end
    end
  end
end
