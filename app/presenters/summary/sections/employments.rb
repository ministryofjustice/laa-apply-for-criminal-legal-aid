module Summary
  module Sections
    class Employments < Sections::BaseSection
      def answers
        return [] if employments.empty?

        Components::Employment.with_collection(
          employments, show_actions: editable?, show_record_actions: headless?
        )
      end

      def list?
        return false if employments.empty?

        true
      end

      private

      def employments
        @employments ||= crime_application.employments
      end
    end
  end
end
