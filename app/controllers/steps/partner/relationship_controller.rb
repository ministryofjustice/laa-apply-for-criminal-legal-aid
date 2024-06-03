module Steps
  module Partner
    class RelationshipController < Steps::PartnerStepController
      def edit
        @form_object = RelationshipForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(RelationshipForm, as: :relationship)
      end
    end
  end
end
