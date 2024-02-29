module Summary
  module Components
    class GroupedList < ViewComponent::Base
       def initialize(items:, group_by:, item_component:)
         @items = items
         @group_by = group_by
         @item_component = item_component
       end

       attr_reader :items, :group_by, :item_component

       def groups
         items.group_by(&group_by.to_sym).map do |group|
            render item_component.with_collection(group.last)
          end
       end

       def call
         safe_join(groups)
       end
    end
  end
end
