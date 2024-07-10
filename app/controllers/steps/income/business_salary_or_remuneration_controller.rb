module Steps
  module Income
    class BusinessSalaryOrRemunerationController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessSalaryOrRemunerationForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessSalaryOrRemunerationForm,
          record: business_record,
          as: :business_salary_or_remuneration
        )
      end

      private

      def additional_permitted_params
        [salary: [:amount]]
      end
    end
  end
end
