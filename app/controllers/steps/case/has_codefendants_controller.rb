module Steps
  module Case
    class HasCodefendantsController < Steps::CaseStepController
      def edit
        @form_object = HasCodefendantsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasCodefendantsForm, as: :has_codefendants)
      end
    end
  end
end
