module Evidence
  module Rules
    class SalariedEmployee < Rule
      include Evidence::RuleDsl

      key :income_employed_0a
      group :income

      client do |crime_application|
        if crime_application.income
          [EmploymentStatus::EMPLOYED.to_s].intersect?(
            Array.wrap(crime_application.income.employment_status)
          )
        else
          false
        end
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
