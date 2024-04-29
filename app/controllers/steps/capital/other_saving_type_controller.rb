module Steps
  module Capital
    class OtherSavingTypeController < Steps::CapitalStepController
      def edit
        @form_object = OtherSavingTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(OtherSavingTypeForm, as: :saving_type)
      end

      private

      def additional_permitted_params
        [:saving_type]
      end
    end
  end
end
