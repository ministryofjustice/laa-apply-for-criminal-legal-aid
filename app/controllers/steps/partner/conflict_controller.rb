module Steps
  module Partner
    class ConflictController < Steps::PartnerStepController
      def edit
        @form_object = ConflictForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ConflictForm, as: :conflict)
      end
    end
  end
end
