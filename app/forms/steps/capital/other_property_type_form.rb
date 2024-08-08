module Steps
  module Capital
    class OtherPropertyTypeForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      attr_accessor :property_type
      attr_reader :property

      validate :property_type_selected

      def choices
        PropertyType.values
      end

      private

      def property_type_selected
        return if PropertyType.values.map(&:to_s).include? property_type.to_s

        errors.add(:property_type, :blank, subject:)
      end

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
