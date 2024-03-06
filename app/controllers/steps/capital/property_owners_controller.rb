module Steps
  module Capital
    class PropertyOwnersController < Steps::CapitalStepController
      def edit
        @form_object = PropertyOwnerForm.build(
          property_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          PropertyOwnerForm, record: property_record, as: step_name, flash: flash_msg
        )
      end

      private

      def step_name
        if params.key?('add_property_owner')
          :add_property_owner
        elsif params.to_s.include?('"_destroy"=>"1"')
          :delete_property_owner
        else
          :property_owners
        end
      end

      def flash_msg
        { success: t('.edit.deleted_flash') } if step_name.eql?(:delete_property_owner)
      end

      def property_record
        @property_record ||= current_crime_application.properties.find(params[:property_id])
      end

      def additional_permitted_params
        [property_owners_attributes: Steps::Capital::PropertyOwnerFieldsetForm.attribute_names]
      end
    end
  end
end
