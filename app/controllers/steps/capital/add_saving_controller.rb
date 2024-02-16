module Steps
  module Capital
    class AddSavingController < Steps::CapitalStepController
      def edit
        @form_object = AddSavingForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AddSavingForm, as: :add_saving)
      end
    end
  end
end
