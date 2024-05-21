module Summary
  module Sections
    class Offences < Sections::BaseSection
      def show?
        crime_application.kase.present? && super
      end

      def answers
        Summary::Components::Offence.with_collection(
          offences,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end

      def list?
        true
      end

      private

      def offences
        @offences ||= crime_application.kase.charges
      end
    end
  end
end
