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

      partner do |crime_application|
        if MeansStatus.include_partner?(crime_application) && crime_application.income
          [EmploymentStatus::EMPLOYED.to_s].intersect?(
            Array.wrap(crime_application.income.partner_employment_status)
          )
        else
          false
        end
      end
    end
  end
end
