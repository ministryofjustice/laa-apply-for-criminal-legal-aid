module Steps
  module Capital
    class PropertyOwnersForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      delegate :property_owners_attributes=, to: :record

      validates_with CapitalAssessment::PropertyOwnersValidator,
                     unless: [:any_marked_for_destruction?, :adding_property_owner?]

      def property_owners
        @property_owners ||= record.property_owners.map do |property_owner|
          PropertyOwnerFieldsetForm.build(
            property_owner, crime_application:
          )
        end
      end

      def any_marked_for_destruction?
        property_owners.any?(&:_destroy)
      end

      def show_destroy?
        property_owners.size > 1
      end

      def relationships
        PropertyRelationshipType.values
      end

      private

      # If validation passes, the actual saving of the `property` performs
      # the updates or destroys of the associated `property_owners` records,
      # as we are using `accepts_nested_attributes_for`
      def persist!
        record.save
      end

      def adding_property_owner?
        step_name.eql?(:add_property_owner)
      end
    end
  end
end
