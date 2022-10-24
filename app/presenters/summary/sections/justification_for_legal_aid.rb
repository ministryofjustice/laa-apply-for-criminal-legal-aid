module Summary
  module Sections
    class JustificationForLegalAid < Sections::BaseSection
      def name
        :justification_for_legal_aid
      end

      def show?
        kase&.ioj.present? && super
      end

      def answers
        [
          ioj.types.map do |ioj_type|
            type = IojReasonType.new(ioj_type)
            Components::FreeTextAnswer.new(
              type, ioj[type.justification_field_name],
              change_path: edit_steps_case_ioj_path(anchor: type),
              i18n_opts: { ioj_type: ioj_type.humanize }
            )
          end
        ].flatten.select(&:show?)
      end

      private

      def kase
        @kase ||= crime_application.case
      end

      def ioj
        @ioj ||= kase.ioj
      end
    end
  end
end
