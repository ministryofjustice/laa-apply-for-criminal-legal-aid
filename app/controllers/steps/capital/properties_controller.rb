module Steps
  module Capital
    class PropertiesController < Steps::CapitalStepController
      include Steps::Capital::PropertyUpdateStep

      def confirm_destroy
        @property = property_record
      end

      def destroy
        property_record.destroy

        if properties.reload.any?
          redirect_to edit_steps_capital_properties_summary_path, success: t('.success_flash')
        else
          # If this was the last remaining record, redirect to the property type page
          redirect_to edit_steps_capital_property_type_path, success: t('.success_flash')
        end
      end

      private

      def property_record
        @property_record ||= properties.find(params[:property_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::PropertyNotFound
      end

      def properties
        @properties ||= current_crime_application.properties
      end

      def flash_msg
        nil
      end
    end
  end
end
