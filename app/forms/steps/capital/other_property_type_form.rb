module Steps
  module Capital
    class OtherPropertyTypeForm < Steps::BaseFormObject
      attr_accessor :property_type
      attr_reader :property

      validates :property_type, presence: true
      validates :property_type, inclusion: { in: PropertyType.values.map(&:to_s) }

      def choices
        PropertyType.values
      end

      private

      def persist!
        @property = incomplete_property_for_type || crime_application.properties.create!(property_type:)
      end

      def incomplete_property_for_type
        return nil unless property_type

        crime_application.properties.where(property_type:).reject(&:complete?).first
      end
    end
  end
end
