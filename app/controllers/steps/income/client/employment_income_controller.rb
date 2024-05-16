module Steps
  module Income
    module Client
      class EmploymentIncomeController < Steps::IncomeStepController
        def edit
          @form_object = EmploymentIncomeForm.build(
            current_crime_application
          )
        end

        def update
          update_and_advance(EmploymentIncomeForm, as: :client_employment_income)
        end
      end
    end
  end
end
