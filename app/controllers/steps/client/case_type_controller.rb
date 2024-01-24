module Steps
  module Client
    class CaseTypeController < Steps::ClientStepController
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
