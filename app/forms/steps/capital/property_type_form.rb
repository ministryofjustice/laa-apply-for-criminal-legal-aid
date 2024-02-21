module Steps
  module Capital
    class PropertyTypeForm < Steps::BaseFormObject
      attr_accessor :property_type

      validates :property_type, presence: true

      attr_reader :property

      def choices
        PropertyType.values
      end

      private

      def persist!
        return true if property_type == 'none'

        @property = incomplete_property_for_type || crime_application.applicant.properties.create(property_type:)
      end

      def incomplete_property_for_type
        return nil unless property_type

        crime_application.applicant.properties.where(property_type:).reject(&:complete?).first
      end
    end
  end
end
