module Steps
  module Capital
    class AddPropertyController < Steps::CapitalStepController
      def edit
        @form_object = AddPropertyForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AddPropertyForm, as: :add_property)
      end
    end
  end
end
