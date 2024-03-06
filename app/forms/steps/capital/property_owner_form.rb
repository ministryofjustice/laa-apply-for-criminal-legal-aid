module Steps
  module Capital
    class PropertyOwnerForm < Steps::BaseFormObject
      # transient attribute
      attr_accessor :property_owners_attributes

      validates_with PropertyOwnersValidator, unless: :any_marked_for_destruction?

      def property_owners
        @property_owners ||= property_owners_collection.map do |property_owner|
          PropertyOwnerFieldsetForm.new(property_owner)
        end
      end

      def any_marked_for_destruction?
        property_owners.any?(&:_destroy)
      end

      def show_destroy?
        property_owners.size > 1
      end

      private

      def property_owners_collection
        if property_owners_attributes
          # This is a params hash in the format:
          # {"0"=>
          #   {"name"=>"ab", "relationship"=>"custom", "custom_relationship"=>"de", "percentage_owned"=>"32", "id"=>"1"}
          # }
          property_owners_attributes.values
        else
          record.property_owners.map do |po|
            po.slice(:id, :name, :relationship, :custom_relationship, :percentage_owned)
          end
        end
      end

      def persist!
        record.update(
          attributes.merge(
            property_owners_attributes:
          )
        )
      end
    end
  end
end