module Steps
  module Capital
    class ResidentialPropertyController < PropertiesController
      private

      def advance_as
        :residential_property
      end

      def form_name
        ResidentialForm
      end
    end
  end
end
