module Steps
  module Capital
    class LandController < PropertiesController
      private

      def advance_as
        :land
      end

      def form_name
        LandForm
      end
    end
  end
end
