module Summary
  module Sections
    class NextCourtHearing < Sections::BaseSection
      def show?
        kase.present? && super
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::FreeTextAnswer.new(
            :hearing_court_name, kase.hearing_court_name,
            change_path: edit_steps_case_hearing_details_path
          ),

          Components::DateAnswer.new(
            :hearing_date, kase.hearing_date,
            change_path: edit_steps_case_hearing_details_path
          ),

          Components::ValueAnswer.new(
            :is_first_court_hearing, kase.is_first_court_hearing,
            change_path: edit_steps_case_hearing_details_path
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength

      private

      def kase
        @kase ||= crime_application.case
      end
    end
  end
end
