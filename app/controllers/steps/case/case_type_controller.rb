module Steps
  module Case
    class CaseTypeController < Steps::CaseStepController
      def edit
        @form_object = CaseTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(CaseTypeForm, as: :case_type)
      end
    end
  end
end
