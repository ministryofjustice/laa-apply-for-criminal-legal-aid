module Steps
  module Capital
    class ResidentialPropertyController < Steps::CapitalStepController
      include Steps::Capital::PropertyStep

      private

      def advance_as
        :residential_property
      end

      def form_name
        ResidentialPropertyForm
      end
    end
  end
end
