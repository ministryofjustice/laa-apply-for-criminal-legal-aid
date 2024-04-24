module Steps
  module Capital
    class PropertyOwnersForm < Steps::BaseFormObject
      delegate :property_owners_attributes=, to: :record

      validates_with CapitalAssessment::PropertyOwnersValidator,
                     unless: [:any_marked_for_destruction?, :incomplete_property_owners?]

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
        RelationshipType.values
      end

      private

      # If validation passes, the actual saving of the `property` performs
      # the updates or destroys of the associated `property_owners` records,
      # as we are using `accepts_nested_attributes_for`
      def persist!
        record.save
      end

      def incomplete_property_owners?
        step_name.eql?(:add_property_owner)
      end
    end
  end
end
