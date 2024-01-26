module Steps
  module Case
    class IsClientRemandedController < Steps::CaseStepController
      def edit
        @form_object = IsClientRemandedForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IsClientRemandedForm, as: :is_client_remanded)
      end
    end
  end
end
