module Steps
  module Capital
    class CommercialPropertyController < PropertiesController
      private

      def advance_as
        :commercial_property
      end

      def form_name
        CommercialForm
      end
    end
  end
end
