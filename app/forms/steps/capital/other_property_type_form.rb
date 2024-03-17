module Steps
  module Capital
    class OtherPropertyTypeForm < PropertyTypeForm
      private

      def persist!
        @property = incomplete_property_for_type || crime_application.properties.create!(property_type:)
      end
    end
  end
end
