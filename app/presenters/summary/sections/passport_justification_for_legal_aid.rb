module Summary
  module Sections
    class PassportJustificationForLegalAid < Sections::BaseSection
      def name
        :passport_justification_for_legal_aid
      end

      def show?
        kase&.ioj.nil? && kase.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :passport, ioj_passport.any?
          ),
        ].select(&:show?)
      end

      private

      def kase
        @kase ||= crime_application.case
      end

      def ioj_passport
        @ioj_passport ||= kase.ioj_passport
      end
    end
  end
end
