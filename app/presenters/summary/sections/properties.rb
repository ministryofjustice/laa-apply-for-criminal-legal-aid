module Summary
  module Sections
    class Properties < Sections::BaseSection
      def show?
        capital && requires_full_capital
      end

      def answers # rubocop:disable Metrics/MethodLength
        if properties.empty?
          [
            Components::ValueAnswer.new(
              :has_assets, 'no',
              change_path: edit_steps_capital_property_type_path
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

      def list?
        return false if properties.empty?

        true
      end

      private

      def properties
        @properties ||= crime_application.properties
      end

      def capital
        @capital ||= crime_application.capital
      end

      def requires_full_capital
        [
          CaseType::EITHER_WAY.to_s,
          CaseType::INDICTABLE.to_s,
          CaseType::ALREADY_IN_CROWN_COURT.to_s
        ].include?(crime_application.case.case_type)
      end
    end
  end
end
