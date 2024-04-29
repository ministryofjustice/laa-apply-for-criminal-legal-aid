module Steps
  module Client
    class ResidenceTypeController < Steps::ClientStepController
      def edit
        @form_object = ResidenceTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ResidenceTypeForm, as: :residence_type)
      end
    end
  end
end
