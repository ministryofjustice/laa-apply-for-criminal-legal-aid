module Summary
  module Sections
    class JustificationForLegalAid < Sections::BaseSection
      def show?
        ioj.present? && super
      end

      def answers
        [
          ioj.types.map do |ioj_type|
            type = IojReasonType.new(ioj_type)
            Components::FreeTextAnswer.new(
              type, ioj[type.justification_field_name],
              change_path: edit_steps_case_ioj_path(anchor: type)
            )
          end
        ].flatten.select(&:show?)
      end

      private

      def ioj
        @ioj ||= crime_application.ioj
      end
    end
  end
end
