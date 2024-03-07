module Steps
  module Capital
    class OtherPropertyTypeController < PropertyTypeController
      def edit
        @form_object = OtherPropertyTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(OtherPropertyTypeForm, as: :property_type)
      end
    end
  end
end
