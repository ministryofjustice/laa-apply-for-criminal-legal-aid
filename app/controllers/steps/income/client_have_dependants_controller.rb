module Steps
  module Income
    class ClientHaveDependantsController < Steps::IncomeStepController
      def edit
        @form_object = ClientHaveDependantsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ClientHaveDependantsForm, as: :client_have_dependants)
      end
    end
  end
end
