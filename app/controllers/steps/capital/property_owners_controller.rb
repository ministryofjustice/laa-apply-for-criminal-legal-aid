module Steps
  module Capital
    class PropertyOwnersController < Steps::CapitalStepController
      include Steps::Capital::PropertyUpdateStep

      private

      def form_name
        PropertyOwnersForm
      end

      def advance_as
        if params.key?('add_property_owner')
          :add_property_owner
        elsif params.to_s.include?('"_destroy" => "1"')
          :delete_property_owner
        else
          :property_owners
        end
      end

      def flash_msg
        { success: t('.edit.deleted_flash') } if advance_as.eql?(:delete_property_owner)
      end

      def additional_permitted_params
        [{ property_owners_attributes: Steps::Capital::PropertyOwnerFieldsetForm.attribute_names }]
      end
    end
  end
end
