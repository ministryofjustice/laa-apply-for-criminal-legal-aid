module Steps
  module Client
    class RelationshipStatusController < Steps::ClientStepController
      def edit
        @form_object = RelationshipStatusForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(RelationshipStatusForm, as: :relationship_status)
      end
    end
  end
end
