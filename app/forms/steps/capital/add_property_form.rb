module Steps
  module Capital
    class AddPropertyForm < Steps::BaseFormObject
      attr_accessor :property_type

      def choices
        PropertyType.values
      end

      private

      def persist!
        # TODO: If none, go to next step
        # If type selected, build new properties form
      end
    end
  end
end
