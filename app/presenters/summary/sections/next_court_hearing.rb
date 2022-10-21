module Summary
  module Sections
    class NextCourtHearing < Sections::BaseSection
      def name
        :next_court_hearing
      end

      def show?
        kase.present? && super
      end

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
        ].select(&:show?)
      end

      private

      def kase
        @kase ||= crime_application.case
      end
    end
  end
end
