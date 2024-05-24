module Steps
  module Income
    module Client
      class EmploymentsController < Steps::IncomeStepController
        include Steps::Income::Client::EmploymentUpdateStep
      end
    end
  end
end
