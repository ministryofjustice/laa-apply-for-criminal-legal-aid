module Steps
  module Income
    class ClientHasDependantsController < Steps::IncomeStepController
      def edit
        @form_object = ClientHasDependantsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ClientHasDependantsForm, as: :client_has_dependants)
      end
    end
  end
end
