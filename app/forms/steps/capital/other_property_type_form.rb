module Steps
  module Capital
    class OtherPropertyTypeForm < Steps::BaseFormObject
      attr_accessor :property_type
      attr_reader :property

      validate :property_type_selected

      def choices
        PropertyType.values
      end

      private

      def property_type_selected
        return if PropertyType.values.map(&:to_s).include? property_type.to_s

        errors.add(:property_type, subject_aware_error_message(:property_type))
      end

      def persist!
        return true if property_type == ''

        @property = incomplete_property_for_type || crime_application.properties.create!(property_type:)
      end

      def incomplete_property_for_type
        return nil unless property_type

        crime_application.properties.where(property_type:).reject(&:complete?).first
      end
    end
  end
end
