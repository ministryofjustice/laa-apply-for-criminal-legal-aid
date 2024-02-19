module Steps
  module Capital
    class PropertyTypeController < Steps::CapitalStepController
      def edit
        @form_object = PropertyTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PropertyTypeForm, as: :property_type)
      end

      def additional_permitted_params
        [:property_type]
      end
    end
  end
end
