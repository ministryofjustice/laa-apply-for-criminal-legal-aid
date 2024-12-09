module Summary
  module Sections
    class ClientEmployments < Sections::BaseSection
      def show?
        income.present? && employments.present?
      end

      def answers
        Components::Employment.with_collection(
          employments, show_actions: editable?, show_record_actions: headless?,
          crime_application: crime_application
        )
      end

      def list?
        return false if employments.empty?

        true
      end

      private

      def employments
        @employments ||= income.client_employments
      end
    end
  end
end
