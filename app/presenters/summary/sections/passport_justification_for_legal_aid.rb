module Summary
  module Sections
    class PassportJustificationForLegalAid < Sections::BaseSection
      def name
        :passport_justification_for_legal_aid
      end

      def show?
        kase.present? && super
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
        crime_application.ioj.nil? && kase.ioj_passport.any?
      end

      def kase
        @kase ||= crime_application.case
      end
    end
  end
end
