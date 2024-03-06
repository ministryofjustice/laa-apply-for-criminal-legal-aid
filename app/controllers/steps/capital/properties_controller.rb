module Steps
  module Capital
    class PropertiesController < Steps::CapitalStepController
      include Steps::Capital::PropertyUpdateStep

      private

      def flash_msg
        nil
      end
    end
  end
end
