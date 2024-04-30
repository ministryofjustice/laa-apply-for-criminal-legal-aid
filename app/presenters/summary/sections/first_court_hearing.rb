module Summary
  module Sections
    class FirstCourtHearing < Sections::BaseSection
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
    end
  end
end
