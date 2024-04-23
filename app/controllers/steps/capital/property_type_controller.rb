module Steps
  module Capital
    class PropertyTypeController < Steps::CapitalStepController
      before_action :require_no_property

      def edit
        @form_object = PropertyTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PropertyTypeForm, as: :property_type)
      end

      private

      def additional_permitted_params
        [:property_type]
      end

      def require_no_property
        return true if current_crime_application.properties.empty?

        redirect_to edit_steps_capital_properties_summary_path(current_crime_application)
      end
    end
  end
end
