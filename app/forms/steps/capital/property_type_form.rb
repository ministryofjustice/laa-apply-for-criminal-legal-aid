module Steps
  module Capital
    class PropertyTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      has_one_association :capital

      attr_writer :property_type
      attr_reader :property

      validate :property_type_selected
      validates :has_no_properties, inclusion: { in: ['yes', nil] }

      def choices
        PropertyType.values
      end

      def property_type
        return @property_type if @property_type

        'none' if capital.has_no_properties == 'yes'
      end

      def has_no_properties
        'yes' if property_type == 'none'
      end

      private

      def property_type_selected
        return if (PropertyType.values.map(&:to_s) << 'none').include? property_type.to_s

        errors.add(:property_type, :blank, subject:)
      end

      def persist!
        capital.update(has_no_properties:)

        if property_type == 'none'
          crime_application.properties.destroy_all
          return true
        end

        @property = incomplete_property_for_type || crime_application.properties.create!(property_type:)
      end

      def incomplete_property_for_type
        return nil unless property_type

        crime_application.properties.where(property_type:).reject(&:complete?).first
      end
    end
  end
end
