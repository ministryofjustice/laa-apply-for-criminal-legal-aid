module Steps
  module Partner
    class InvolvementTypeController < Steps::PartnerStepController
      def edit
        @form_object = InvolvementTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(InvolvementTypeForm, as: :involvement_type)
      end
    end
  end
end
