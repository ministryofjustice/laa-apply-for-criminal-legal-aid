module Steps
  module Income
    class ArmedForcesController < Steps::IncomeStepController
      include SubjectResource

      def edit
        @form_object = ArmedForcesForm.new(
          crime_application: current_crime_application,
          subject: @subject
        )
      end

      def update
        update_and_advance(ArmedForcesForm, as: :armed_forces, subject: @subject)
      end
    end
  end
end
