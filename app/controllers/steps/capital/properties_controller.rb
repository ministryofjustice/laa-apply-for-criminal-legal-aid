module Steps
  module Capital
    class PropertiesController < Steps::CapitalStepController
      include Steps::Capital::PropertyStep

      private

      # :nocov:
      def advance_as
        raise NotImplementedError
      end

      def form_name
        raise NotImplementedError
      end
      # :nocov:
    end
  end
end
