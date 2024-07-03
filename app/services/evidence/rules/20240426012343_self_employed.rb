module Evidence
  module Rules
    class SelfEmployed < Rule
      include Evidence::RuleDsl

      key :income_selfemployed_3
      group :income

      client do |crime_application|
        self_employed_status = [
          EmploymentStatus::SELF_EMPLOYED.to_s,
        ]

        self_employed_status.intersect?(
          Array.wrap(crime_application.income&.employment_status)
        )
      end

      partner do |crime_application|
        if MeansStatus.include_partner?(crime_application)
          [EmploymentStatus::SELF_EMPLOYED.to_s].intersect?(
            Array.wrap(crime_application.income&.partner_employment_status)
          )
        else
          false
        end
      end
    end
  end
end
