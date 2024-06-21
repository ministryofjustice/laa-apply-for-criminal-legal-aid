module Steps
  module Income
    module Partner
      class EmploymentIncomeController < Steps::Income::Client::EmploymentIncomeController
        private

        def advance_as
          :partner_employment_income
        end

        def form_name
          Steps::Income::Partner::EmploymentIncomeForm
        end
      end
    end
  end
end
