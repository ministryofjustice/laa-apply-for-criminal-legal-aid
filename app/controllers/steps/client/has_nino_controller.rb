module Steps
  module Client
    class HasNinoController < Steps::ClientStepController
      def edit
        @form_object = HasNinoForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasNinoForm, as: :has_nino)
      end
    end
  end
end
