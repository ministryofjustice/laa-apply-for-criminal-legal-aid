module Steps
  module Capital
    class PropertiesController < Steps::CapitalStepController
      def edit
        @form_object = PropertyTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PropertyTypeForm, as: :properties)
      end

      def additional_permitted_params
        [:property_type]
      end
    end
  end
end
