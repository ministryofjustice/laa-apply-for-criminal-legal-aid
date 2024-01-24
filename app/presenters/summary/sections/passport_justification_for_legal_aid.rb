module Summary
  module Sections
    class PassportJustificationForLegalAid < Sections::BaseSection
      def answers
        [
          Components::ValueAnswer.new(
            :passport, passport_triggered?
          ),
          Components::ValueAnswer.new(
            :passport_override, passport_override?,
            change_path: edit_steps_case_ioj_path
          ),
        ].select(&:show?)
      end

      private

      def ioj
        @ioj ||= crime_application.ioj
      end

      def passport_triggered?
        ioj.blank? && crime_application.ioj_passport.any?
      end

      def passport_override?
        ioj.present? && ioj.types.blank? && ioj.passport_override
      end
    end
  end
end
