module Summary
  module Components
    class GroupedList < ViewComponent::Base
      def initialize(items:, group_by:, item_component:, show_actions: true, show_record_actions: false)
        @items = items
        @group_by = group_by
        @item_component = item_component
        @show_actions = show_actions
        @show_record_actions = show_record_actions

        super
      end

      attr_reader :items, :group_by, :item_component, :show_actions, :show_record_actions

      def groups
        items.group_by(&group_by.to_sym).map(&:last)
      end
    end
  end
end
