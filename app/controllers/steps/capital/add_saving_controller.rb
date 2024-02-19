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

      def additional_permitted_params
        [:saving_type]
      end
    end
  end
end
