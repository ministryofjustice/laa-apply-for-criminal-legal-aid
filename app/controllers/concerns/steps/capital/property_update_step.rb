module Steps
  module Capital
    module PropertyUpdateStep
      extend ActiveSupport::Concern

      def edit
        @form_object = form_name.build(
          property_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          form_name, record: property_record, as: advance_as, flash: flash_msg
        )
      end

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

      # :nocov:
      def advance_as
        raise NotImplementedError
      end

      def form_name
        raise NotImplementedError
      end

      def flash_msg
        nil
      end
      # :nocov:
    end
  end
end
