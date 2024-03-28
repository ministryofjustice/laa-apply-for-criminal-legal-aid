module Summary
  module Sections
    class Codefendants < Sections::BaseSection
      def show?
        kase.present? && super
      end

      def answers
        Components::Codefendant.with_collection(
          codefendants, show_actions: editable?, show_record_actions: headless?
        )
      end

      def list?
        true
      end

      private

      def kase
        @kase ||= crime_application.case
      end

      def codefendants
        @codefendants ||= kase.codefendants
      end
    end
  end
end
