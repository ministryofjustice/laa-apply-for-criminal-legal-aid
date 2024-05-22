module Summary
  module Sections
    class Employments < Sections::BaseSection
      def show?
        shown_question?
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        if no_employments?
          [
            Components::ValueAnswer.new(
              :has_employments, 'none',
              change_path: edit_steps_capital_property_type_path
            )
          ]
        else
          Summary::Components::GroupedList.new(
            items: employments,
            group_by: :ownership_type,
            item_component: Summary::Components::Employment,
            show_actions: editable?,
            show_record_actions: headless?
          )
        end
      end
      # rubocop:enable Metrics/MethodLength

      def list?
        return false if employments.empty?

        true
      end

      private

      def employments
        @employments ||= crime_application.employments
      end

      # def shown_question?
      #   capital.present? && (no_employments? || employments.present?)
      # end
      #
      def no_employments?
        return false if crime_application.employments.nil?

        #YesNoAnswer.new(crime_application.employments.nil?).yes?
      end
    end
  end
end
