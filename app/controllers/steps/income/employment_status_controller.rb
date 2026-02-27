module Steps
  module Income
    class EmploymentStatusController < Steps::IncomeStepController
      def edit
        @form_object = EmploymentStatusForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(EmploymentStatusForm, as: :employment_status)
      end

      private

      def additional_permitted_params
        [{ employment_status: [] }]
      end
    end
  end
end
