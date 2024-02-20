module Steps
  module Capital
    class SavingTypeController < Steps::CapitalStepController
      def edit
        @form_object = SavingTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(SavingTypeForm, as: :savings)
      end

      def additional_permitted_params
        [:saving_type]
      end
    end
  end
end
