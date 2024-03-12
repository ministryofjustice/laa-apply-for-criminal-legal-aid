module Steps
  module Capital
    class OtherPropertyTypeForm < PropertyTypeForm
      private

      def persist!
        @property = crime_application.properties.create!(property_type:)
      end
    end
  end
end
