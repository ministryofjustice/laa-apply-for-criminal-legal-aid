module Summary
  module Components
    class GroupedList < ViewComponent::Base
      def initialize(items:, item_component:, group_by: nil, show_actions: true, show_record_actions: false, # rubocop:disable Metrics/ParameterLists
                     crime_application: nil)
        @items = items
        @group_by = group_by
        @item_component = item_component
        @show_actions = show_actions
        @show_record_actions = show_record_actions
        @crime_application = crime_application

        super
      end

      attr_reader :items, :item_component, :show_actions, :show_record_actions, :crime_application

      def groups
        items.group_by(&group_by.to_sym).map(&:last)
      end

      def group_by
        @group_by ||= item_component::GROUP_BY
      end
    end
  end
end
