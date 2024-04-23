module Steps
  module Capital
    class OtherPropertyTypeController < Steps::CapitalStepController
      def edit
        @form_object = OtherPropertyTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(OtherPropertyTypeForm, as: :property_type)
      end

      private

      def additional_permitted_params
        [:property_type]
      end
    end
  end
end
