module Summary
  module Sections
    class PassportJustificationForLegalAid < Sections::BaseSection
      def name
        :passport_justification_for_legal_aid
      end

      def answers
        [
          Components::ValueAnswer.new(
            :passport, passport_triggered?
          ),
        ].select(&:show?)
      end

      private

      def passport_triggered?
        crime_application.ioj.blank? && crime_application.ioj_passport.any?
      end
    end
  end
end
