module Steps
  module Partner
    class InvolvementController < Steps::PartnerStepController
      def edit
        @form_object = InvolvementForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(InvolvementForm, as: :involvement)
      end
    end
  end
end
