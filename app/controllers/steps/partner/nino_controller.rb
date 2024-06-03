module Steps
  module Partner
    class NinoController < Steps::PartnerStepController
      def edit
        @form_object = NinoForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(NinoForm, as: :nino)
      end
    end
  end
end
