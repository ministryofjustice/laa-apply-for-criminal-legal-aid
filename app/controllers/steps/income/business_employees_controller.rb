module Steps
  module Income
    class BusinessEmployeesController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessEmployeesForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessEmployeesForm,
          record: business_record,
          as: :business_employees
        )
      end
    end
  end
end
