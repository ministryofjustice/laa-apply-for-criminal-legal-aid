module Steps
  module Client
    class HasNinoController < Steps::ClientStepController
      def edit
        @form_object = NinoForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(NinoForm, as: :has_nino)
      end

      private

      def additional_permitted_params
        [:has_arc_or_nino]
      end
    end
  end
end
