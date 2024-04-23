module Summary
  module Sections
    class Properties < Sections::BaseSection
      def show?
        shown_question?
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        if no_properties?
          [
            Components::ValueAnswer.new(
              :has_assets, 'none',
              change_path: edit_steps_capital_properties_summary_path
            )
          ]
        else
          Summary::Components::GroupedList.new(
            items: properties,
            group_by: :property_type,
            item_component: Summary::Components::Property,
            show_actions: editable?,
            show_record_actions: headless?
          )
        end
      end
      # rubocop:enable Metrics/MethodLength

      def list?
        return false if properties.empty?

        true
      end

      private

      def capital
        @capital ||= crime_application.capital
      end

      def properties
        @properties ||= crime_application.properties
      end

      def shown_question?
        capital.present? && (no_properties? || properties.present?)
      end

      def no_properties?
        return false if capital.has_no_properties.nil?

        YesNoAnswer.new(capital.has_no_properties).yes?
      end
    end
  end
end
