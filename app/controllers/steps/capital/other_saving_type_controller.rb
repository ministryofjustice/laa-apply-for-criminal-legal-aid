module Steps
  module Capital
    class OtherSavingTypeController < SavingTypeController
      def edit
        @form_object = OtherSavingTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(OtherSavingTypeForm, as: :saving_type)
      end
    end
  end
end
