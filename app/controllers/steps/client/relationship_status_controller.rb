module Steps
  module Client
    class RelationshipStatusController < Steps::ClientStepController
      def edit
        @form_object = RelationshipStatusForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(RelationshipStatusForm, as: :has_partner)
      end
    end
  end
end
