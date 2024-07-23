module Steps
  module Case
    class HasCodefendantsController < Steps::CaseStepController
      before_action :redirect_cifc

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
