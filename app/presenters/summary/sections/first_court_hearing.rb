module Summary
  module Sections
    class FirstCourtHearing < Sections::BaseSection
      def name
        :first_court_hearing
      end

      def show?
        kase.present? && super
      end

      def answers
        [
          Components::FreeTextAnswer.new(
            :first_court_hearing_name, kase.first_court_hearing_name,
            change_path: edit_steps_case_first_court_hearing_path
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
