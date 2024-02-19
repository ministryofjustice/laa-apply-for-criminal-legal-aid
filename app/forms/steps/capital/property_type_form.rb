module Steps
  module Capital
    class PropertyTypeForm < Steps::BaseFormObject
      attr_accessor :property_type

      validates :property_type, presence: true

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
