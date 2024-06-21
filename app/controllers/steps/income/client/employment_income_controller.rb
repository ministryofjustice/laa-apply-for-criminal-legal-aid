module Steps
  module Income
    module Client
      class EmploymentIncomeController < Steps::IncomeStepController
        def edit
          @form_object = form_name.build(
            current_crime_application
          )
        end

        def update
          update_and_advance(form_name, as: advance_as)
        end

        private

        def form_name
          Steps::Income::Client::EmploymentIncomeForm
        end

        def advance_as
          :client_employment_income
        end
      end
    end
  end
end
