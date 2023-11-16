module Steps
  module Income
    class ClientOwnsPropertyController < Steps::IncomeStepController
      def edit
        @form_object = ClientOwnsPropertyForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ClientOwnsPropertyForm, as: :client_owns_property)
      end
    end
  end
end
