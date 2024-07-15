module Summary
  module Sections
    class BaseCapitalRecordsSection < Sections::BaseSection
      def show?
        return false if capital.blank?

        records.present? || has_records_answer.present?
      end

      def answers
        return list_component if records.present?

        [has_no_records_component]
      end

      def list?
        records.present?
      end

      private

      def list_component
        Summary::Components::GroupedList.new(
          items: records,
          item_component: item_component_class,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end

      # :nocov: #
      def item_component_class
        raise 'must be implemented in subclasses'
      end

      def has_no_records_component
        raise 'must be implemented in subclasses'
      end

      def records
        raise 'must be implemented in subclasses'
      end

      def has_records_answer
        raise 'must be implemented in subclasses'
      end
      # :nocov: #
    end
  end
end
