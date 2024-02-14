module Steps
  module Case
    class HasCaseConcludedController < Steps::CaseStepController
      def edit
        @form_object = HasCaseConcludedForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasCaseConcludedForm, as: :has_case_concluded, validate_draft: true)
      end
    end
  end
end
